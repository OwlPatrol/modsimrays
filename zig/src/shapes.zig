const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Material = @import("materials.zig").Material;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Point = @Vector(3, f64);
const HittableList = @import("hitlist.zig").HittableList;
const uintRand = @import("main.zig").uintRand;
const BoxComparator = fn (box0: BoundingBox, box1: BoundingBox) bool;
const sort = std.sort.sort;


pub const Shape = union(enum) {
    sphere: Sphere,
    moving_sphere: MovingSphere,
    bvhNode: BvhNode,

    pub fn makeBvh(list: *HittableList, timeStart: f64, timeEnd: f64) Shape {
        return BvhNode.initSlice(list, 0, @intCast(u32, list.length()), timeStart, timeEnd);
    }
    pub fn stationarySphere(center: Point, radius: f64, material: Material) Shape {
        return Shape{ .sphere = Sphere{ .center = center, .radius = radius, .material = material } };
    }

    pub fn movingSphere(centerStart: Point, centerStop: Point, timeStart: f64, timeStop: f64, radius: f64, material: Material) Shape {
        return Shape{ .moving_sphere = MovingSphere{ .centerStart = centerStart, .centerStop = centerStop, .timeStart = timeStart, .timeStop = timeStop, .radius = radius, .material = material } };
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
            .moving_sphere => {
                center = self.moving_sphere.center(ray.time);
                radius = self.moving_sphere.radius;
                material = self.moving_sphere.material;
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
            .movingSphere => return self.movingSphere.bounding(timeStart, timeEnd, box),
            .bvhNode => return self.bvhNode.bounding(box),
        }
    }
};

pub const Sphere = struct {
    center: Point,
    radius: f64,
    material: Material,

    pub fn bounding(self: Sphere, box: *BoundingBox) bool {
        const radius = self.radius;
        box.*.min = self.center - Vec3.init(radius, radius, radius);
        box.*.max = self.center + Vec3.init(radius, radius, radius);
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

pub const BvhNode = struct {

    left: *Shape,
    right: *Shape,
    box: BoundingBox,

    fn compareBoxes(a: *Shape, b: *Shape, axis: u32) bool {
        var box_a: BoundingBox = undefined;
        var box_b: BoundingBox = undefined;

        if(!a.*.bounding(0, 0, &box_a) or !b.*.bounding(0, 0, &box_b)) std.debug.print("Wat");
        return box_a.min[axis] < box_b.min[axis];
    }

    fn generateXComparator () fn (void, *Shape, *Shape) bool {
        return struct {
            pub fn inner(_: void, a: *Shape, b: *Shape) bool {
                return compareBoxes(a, b, 0);
            }
        }.inner;
    }

    fn generateYComparator() fn (void, *Shape, *Shape) bool {
        return struct {
            pub fn inner(_: void, a: *Shape, b: *Shape) bool {
                return compareBoxes(a, b, 1); 
            }
        }.inner;
    }

    fn generateZComparator () fn (void, *Shape, *Shape) bool {
        return struct {
            pub fn inner(_: void, a: *Shape, b: *Shape) bool {
                return compareBoxes(a, b, 2); 
            }
        }.inner;
    }

    pub fn initSlice(list: *HittableList, start: u32, end: u32, timeStart: f64, timeEnd:f64) Shape {
        const axis = uintRand(2);
    
        const objects = list.*.objects.items;
        const span = end - start;
        var left: Shape = undefined; var right: Shape = undefined; var box: BoundingBox = undefined;
        switch(span) {
            1 => {
                left = &objects[start]; 
                right = &objects[start];
                box = objects[start].bounding();
                },
            2 => {
                const box0 = objects[start].bounding();
                const box1 = objects[start+1].bounding();
                if(BoundingBox.compareBoxes(box0, box1, axis)) {
                    left = &objects[start];
                    right = &objects[start+1];
                } else {
                    left = &objects[start+1];
                    right = &objects[start];
                }
                box = box0.surroundingBox(box1);
            }, 
            else => {
                switch(axis) {
                    0 => sort(Shape, objects[start..end], {}, generateXComparator()),
                    1 => sort(Shape, objects[start..end], {}, generateYComparator()),
                    2 => sort(Shape, objects[start..end], {}, generateZComparator()),
                    else => unreachable,
                }

                const mid = start + span/2;
                left = initSlice(list, start, mid, timeStart, timeEnd);
                right = initSlice(list, mid, end, timeStart, timeEnd);
            }
        }
        var box_left: BoundingBox = undefined;
        var box_right: BoundingBox = undefined;

        if(!left.bounding(timeStart, timeEnd, &box_left) or !right.bounding(timeStart, timeEnd, &box_right)) 
            std.debug.print("Bro wtf", .{});

        box = BoundingBox.surroundingBox(box_left, box_right);
        return Shape {.bvhNode = BvhNode{.left = &left, .right = &right, .box = box}};
    }

    pub fn hit(self: BvhNode, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        if(!self.box.hit(ray, t_min, t_max)) return false;
        const hit_left = self.left.*.hit(ray, t_min, t_max, rec);
        const hit_right = self.right.*.hit(ray, t_min, if(hit_left) rec.t else t_max, rec);
        
        return (hit_left or hit_right);
    }

    pub fn bounding(self: BvhNode, output: *BoundingBox) bool {
        output.*.min = self.box.min;
        output.*.min = self.box.min;
        return true;
    }
};