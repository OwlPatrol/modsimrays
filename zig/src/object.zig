const Vec3 = @import("vector.zig");
const std = @import("std");
const Ray = @import("rays.zig").Ray;
const HitRecord = @import("hitrecord.zig").HitRecord;

pub const Shapes = enum {
    sphere,
    cube,
};

pub const Shape = union(Shapes) {
    sphere: Sphere,
    cube: Cube,

    pub fn hitShape(self: Shape, ray :Ray, t_min: f32, t_max: f32, hit_rec: *HitRecord) bool {
        switch(self) {
            .sphere => return self.sphere.hit(ray, t_min, t_max, hit_rec),
            .cube => return self.cube.hit(ray, t_min, t_max, hit_rec)
        }
    }

    pub fn init(origin: @Vector(3, f32), len: f32) Shape {
        return Shape {.sphere = Sphere.init(origin, len)};
    }
};

pub const Sphere = struct {
    center: @Vector(3, f32),
    radius: f32,

    pub fn init(center: @Vector(3, f32), radius: f32) Sphere {
        return Sphere {
            .center = center,
            .radius = radius,
        };
    }

    fn hit(self: Sphere, ray: Ray, t_min: f32, t_max: f32, hit_rec: *HitRecord) bool {
        const oc: @Vector(3, f32) = ray.origin - self.center;
        const a = Vec3.dot(ray.dir, ray.dir);
        const b = Vec3.dot(oc, ray.dir);
        const c = Vec3.dot(oc, oc) - self.radius * self.radius;
        const discriminant = b * b - a * c;
        if (discriminant > 0) {
            var temp = (b - @sqrt(discriminant)) / a;
            if (temp > t_min and temp < t_max) {
                hit_rec.*.t = temp;
                hit_rec.*.p = ray.pointsAt(temp);
                hit_rec.*.normal = Vec3.scalar(hit_rec.p - self.center, 1 / self.radius);
                return true;
            }
            temp = (b + @sqrt(discriminant)) / a;
            if (temp > t_min and temp < t_max) {
                hit_rec.*.t = temp;
                hit_rec.*.p = ray.pointsAt(temp);
                hit_rec.*.normal = Vec3.scalar((hit_rec.p - self.center), 1 / self.radius);
                return true;
            }
        }
        return false;
    }
};

pub const Cube = struct {
    origin: @Vector(3, f32),
    length: f32,

    pub fn init(origin: @Vector(3, f32), len: f32) Cube {
        return Cube {
            .origin = origin,
            .length = len,
        };
    }

    fn hit(self: Cube, ray: Ray, t_min: f32, t_max: f32, hit_rec: *HitRecord) bool {
        if (t_min > t_max) return false;
        if (hit_rec.t != 0) return false;
        return (@TypeOf(ray) == @TypeOf(self));
    }
};
