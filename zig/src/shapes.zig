const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Material = @import("materials.zig").Material;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Point = @Vector(3, f64);
const uintRand = @import("utils.zig").uintRand;
const page = std.heap.page_allocator;
const sort = std.sort.sort;
const acos = std.math.acos;
const atan2 = std.math.atan2;
const pi = std.math.pi;

pub const Shape = union(enum) {
    sphere: *Sphere,
    moving_sphere: *MovingSphere,

    pub fn stationarySphere(center: Point, radius: f64, material: *Material) !*Shape {
        const shapeptr = try page.create(Shape);
        const sphereptr = try page.create(Sphere);
        sphereptr.* = Sphere{ .center = center, .radius = radius, .material = material };
        shapeptr.* = Shape{ .sphere =  sphereptr};
        return shapeptr;
    }

    pub fn destroy(self: *Shape) void {
        //switch (self.*) {
        //    .sphere => |s| {
        //        s.destroy();
        //    },
        //    .moving_sphere => |m| {
        //        m.destroy();
        //    }
        //}
        page.destroy(self);
    }

    pub fn movingSphere(centerStart: Point, centerStop: Point, timeStart: f64, timeStop: f64, radius: f64, material: *Material) !*Shape {
        const shapeptr = try page.create(Shape);
        const sphereptr = try page.create(MovingSphere);
        sphereptr.* = MovingSphere{ .centerStart = centerStart, .centerStop = centerStop, .timeStart = timeStart, .timeStop = timeStop, .radius = radius, .material = material };
        shapeptr.* = Shape{ .moving_sphere = sphereptr};
        return shapeptr;
    }

    pub fn hit(self: Shape, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        var center: Point = undefined;
        var radius: f64 = undefined;
        var material: *Material = undefined;
        switch (self) {
            .sphere => |sphere| {
                center = sphere.center;
                radius = sphere.radius;
                material = sphere.material;
            },
            .moving_sphere => |moving_sphere| {
                center = moving_sphere.center(ray.time);
                radius = moving_sphere.radius;
                material = moving_sphere.material;
            },
        }
        const oc = ray.origin - center;
        const a = Vec3.norm(ray.dir);
        const b = Vec3.dot(oc, ray.dir);
        const c = Vec3.norm(oc) - radius * radius;

        const discriminant = b * b - a * c;
        if (discriminant < 0) return false;
        var sqrtd = @sqrt(discriminant);

        var root = (-b - sqrtd) / a;
        if (root < t_min or t_max < root) {
            root = sqrtd - b;
            if (root < t_min or t_max < root) return false;
        }
        rec.*.t = root;
        rec.*.p = ray.at(rec.*.t);
        rec.*.material = material.*;
        var out_normal = Vec3.div((rec.*.p - center), radius);
        Sphere.getUV(out_normal, rec);
        rec.setFaceNormal(ray, out_normal);
        return true;
    }

    pub fn bounding (self: Shape, timeStart:f64, timeEnd:f64) BoundingBox {
        switch(self) {
            .sphere => return self.sphere.bounding(),
            .moving_sphere => return self.moving_sphere.bounding(timeStart, timeEnd),
        }
    }
};

pub const Sphere = struct {
    center: Point,
    radius: f64,
    material: *Material,
    
    pub fn destroy(self: *Sphere) void {
        //self.*.material.destroy();
        page.destroy(self);
    }

    pub fn getUV(point: Point, rec:  *HitRecord) void {
        const theta = acos(-point[1]);
        const phi = atan2(f64, -point[2], point[0] + std.math.pi);
        rec.*.u = phi / (2*pi);
        rec.*.v = theta/pi;
    }

    pub fn bounding(self: Sphere) BoundingBox {
        const radius = self.radius;
        return BoundingBox {
            .min = self.center - Vec3.init(radius, radius, radius), 
            .max = self.center + Vec3.init(radius, radius, radius)
        };
    }
};

pub const MovingSphere = struct {
    centerStart: Point,
    centerStop: Point,
    timeStart: f64,
    timeStop: f64,
    radius: f64,
    material: *Material,

    pub fn destroy(self: MovingSphere) void {
        //self.material.destroy();
        page.destroy(self);
    }

    pub fn center(self: MovingSphere, time: f64) @Vector(3, f64) {
        // Possible cause of errors, assumes time1 > time0
        return self.centerStart + Vec3.scalar(self.centerStop - self.centerStart, (time - self.timeStart) / (self.timeStop - self.timeStart));
    }

    pub fn bounding(self: MovingSphere, timeStart: f64, timeEnd: f64) BoundingBox {
        const radius = self.radius;
        const boxStart = BoundingBox {.min = self.center(timeStart) - Vec3.init(radius, radius, radius), .max = self.center(timeStart) + Vec3.init(radius, radius, radius)};
        const boxEnd = BoundingBox {.min = self.center(timeEnd) - Vec3.init(radius, radius, radius), .max = self.center(timeEnd) + Vec3.init(radius, radius, radius)};
        const surr = BoundingBox.surroundingBox(boxStart, boxEnd);
        return BoundingBox {
            .min = surr.min,
            .max = surr.max,
        };
    }
};

