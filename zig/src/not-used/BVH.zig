const std = @import("std");
const HittableList = @import("hitlist.zig").HittableList;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Ray = @import("ray.zig").Ray;
const Shape = @import("shapes.zig").Shape;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Hittable = @import("hittable.zig").Hittable;
const uintRand = @import("main.zig").uintRand;
const sort = std.sort.sort;

pub const BvhNode = struct {

    left: BvhNode,
    right: BvhNode,
    box: BoundingBox,

    fn compareBoxes(a: Shape, b: Shape, axis: u32) bool {
        return a.bounding(0, 0).min[axis] < b.bounding(0, 0).min[axis];
    }

    fn generateXComparator () fn (void, Shape, Shape) bool {
        return struct {
            pub fn inner(_: void, a: Shape, b: Shape) bool {
                return compareBoxes(a, b, 0);
            }
        }.inner;
    }

    fn generateYComparator() fn (void, Shape, Shape) bool {
        return struct {
            pub fn inner(_: void, a: Shape, b: Shape) bool {
                return compareBoxes(a, b, 1); 
            }
        }.inner;
    }

    fn generateZComparator () fn (void, Shape, Shape) bool {
        return struct {
            pub fn inner(_: void, a: Shape, b: Shape) bool {
                return compareBoxes(a, b, 2); 
            }
        }.inner;
    }

    pub fn initSlice(timeStart: f64, timeEnd:f64, start: u32, end: u32, list: *HittableList) Shape {
        std.debug.print("Hi!", .{});
        const axis = uintRand(2);
    
        const objects = list.*.objects.items;
        const span = end - start;

        var left: Shape = undefined; 
        var right: Shape = undefined; 
        var box: BoundingBox = undefined;

        switch(span) {
            1 => {
                left = objects[start]; 
                right = objects[start];
                box = objects[start].bounding(0, 1);
                return  Shape {.bvhNode = BvhNode{.left = &left, .right = &right, .box = box}};
                },
            2 => {
                if(compareBoxes(objects[start], objects[start+1], axis)) {
                    left = objects[start];
                    right = objects[start+1];
                } else {
                    left = objects[start+1];
                    right = objects[start];
                }
            }, 
            else => {
                switch(axis) {
                    0 => sort(Shape, objects[start..end], {}, generateXComparator()),
                    1 => sort(Shape, objects[start..end], {}, generateYComparator()),
                    2 => sort(Shape, objects[start..end], {}, generateZComparator()),
                    else => unreachable,
                }

                const mid = start + span/2;
                left = initSlice(timeStart, timeEnd, start, mid, list);
                right = initSlice(timeStart, timeEnd, mid, end, list);
            }
        }

        box = BoundingBox.surroundingBox(left.bounding(timeStart, timeEnd), right.bounding(timeStart, timeEnd));
        return Shape {.bvhNode = BvhNode{.left = &left, .right = &right, .box = box}};
    }

    pub fn hit(self: BvhNode, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        if(!self.box.hit(ray, t_min, t_max)) return false;
        const hit_left = self.left.*.hit(ray, t_min, t_max, rec);
        const hit_right = self.right.*.hit(ray, t_min, if(hit_left) rec.t else t_max, rec);
        
        return (hit_left or hit_right);
    }

    pub fn bounding(self: BvhNode) BoundingBox {
        return BoundingBox {.min = self.box.min, .max = self.box.max,};
    }
};