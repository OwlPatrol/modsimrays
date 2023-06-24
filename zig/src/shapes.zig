const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Material = @import("materials.zig").Material;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Point = @Vector(3, f64);
const HittableList = @import("hitlist.zig").HittableList;
const uintRand = @import("main.zig").uintRand;
const BoxComparator= fn (box0: BoundingBox, box1: BoundingBox) bool;


pub const Shape = union(enum) {
    sphere: Sphere,
    movingSphere: MovingSphere,
    bvhNode: BvhNode,

    pub fn stationarySphere(center: Point, radius: f64, material: Material) Shape {
        return Shape{ .sphere = Sphere{ .center = center, .radius = radius, .material = material } };
    }

    pub fn movingSphere(centerStart: Point, centerStop: Point, timeStart: f64, timeStop: f64, radius: f64, material: Material) Shape {
        return Shape{ .movingSphere = MovingSphere{ .centerStart = centerStart, .centerStop = centerStop, .timeStart = timeStart, .timeStop = timeStop, .radius = radius, .material = material } };
    }

    pub fn hit(self: Shape, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        var center: Point = undefined;
        var radius: f64 = undefined;
        var material: Material = undefined;
        switch (self) {
            .bvhNode => return self.bvhNode.hit(ray, t_min, t_max, rec),
            .sphere => {
                center = self.sphere.center;
                radius = self.sphere.radius;
                material = self.sphere.material;
            },
            .movingSphere => {
                center = self.movingSphere.center(ray.time);
                radius = self.movingSphere.radius;
                material = self.movingSphere.material;
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
        rec.*.material = material;
        var out_normal = Vec3.div((rec.*.p - center), radius);
        rec.setFaceNormal(ray, out_normal);
        return true;
    }

    pub fn bounding (self: Shape, timeStart:f64, timeEnd:f64, box: *BoundingBox) bool {
        switch(self) {
            .sphere => return self.sphere.bounding(box),
            .movingSphere => return self.movingSphere.bounding(timeStart, timeEnd, box)
        }
    }
};

pub const Sphere = struct {
    center: Point,
    radius: f64,
    material: Material,

    pub fn bounding(self: Sphere, box: *BoundingBox) bool {
        const radius = self.radius;
        box.*.min = self.sphere.center - Vec3.init(radius, radius, radius);
        box.*.max = self.sphere.center + Vec3.init(radius, radius, radius);
        return true;
    }
};

pub const MovingSphere = struct {
    centerStart: Point,
    centerStop: Point,
    timeStart: f64,
    timeStop: f64,
    radius: f64,
    material: Material,

    pub fn center(self: MovingSphere, time: f64) @Vector(3, f64) {
        // Possible cause of errors, assumes time1 > time0
        return self.centerStart + Vec3.scalar(self.centerStop - self.centerStart, (time - self.timeStart) / (self.timeStop - self.timeStart));
    }

    pub fn bounding(self: MovingSphere, timeStart: f64, timeEnd: f64, box: *BoundingBox) bool {
        const radius = self.radius;
        const boxStart = BoundingBox {.min = self.center(timeStart) - Vec3.init(radius, radius, radius), .max = self.center(timeStart) + Vec3.init(radius, radius, radius)};
        const boxEnd = BoundingBox {.min = self.center(timeEnd) - Vec3.init(radius, radius, radius), .max = self.center(timeEnd) + Vec3.init(radius, radius, radius)};
        const surr = BoundingBox.surroundingBox(boxStart, boxEnd);
        box.*.min = surr.min;
        box.*.max = surr.max;
        return true;
    }
};

const BvhNode = struct {

    left: *Shape,
    right: *Shape,
    box: BoundingBox,

    pub fn init(list: *HittableList, timeStart: f64, timeEnd: f64) BvhNode {
        return initSlice(list, 0, list.size(), timeStart, timeEnd);
    }

    pub fn initSlice(list: *HittableList, start: u32, end: u32, timeStart: f64, timeEnd:f64) BvhNode {
        const axis = uintRand(2);
        const objects = list.*.objects;
        const span = end - start;
        var left = undefined; var right = undefined; var box = undefined;
        const comparator: BoxComparator = BoundingBox.boxCompare(axis);

        switch(span) {
            1 => {
                left = objects[start]; 
                right = objects[start];
                },
            2 => {
                if(BoundingBox(objects[start], objects[start+1], span)) {
                    left = objects[start];
                    right = objects[start+1];
                } else {
                    left = objects[start+1];
                    right = objects[start];
                }
            }, 
            else => {
                std.sort(Shape, objects[start..end], {}, comparator);

                const mid = start + span/2;
                left = initSlice(list, start, mid, timeStart, timeEnd);
                right = initSlice(list, mid, end, timeStart, timeEnd);
            }
        }
        var box_left: BoundingBox = undefined;
        var box_right: BoundingBox = undefined;

        if(!left.*.boundingBox(timeStart, timeEnd, &box_left) or !right.*.boundingBox(timeStart, timeEnd, &box_right)) 
            std.debug.print("Bro wtf", .{});

        box = BoundingBox.surroundingBox(box_left, box_right);
    }

    pub fn hit(self: BvhNode, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        if(!self.box.hit(ray, t_min, t_max)) return false;
        const hit_left = self.left.*.hit(ray, t_min, t_max, rec);
        const hit_right = self.right.*.hit(ray, t_min, if(hit_left) rec.t else t_max, rec);
        
        return (hit_left or hit_right);
    }

    pub fn boundingBox(self: BvhNode, output: *BoundingBox) bool {
        output.*.min = self.box.min;
        output.*.min = self.box.min;
        return true;
    }
};