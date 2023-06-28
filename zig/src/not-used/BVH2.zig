const std = @import("std");
const HittableList = @import("hitlist.zig").HittableList;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Ray = @import("ray.zig").Ray;
const Shape = @import("shapes.zig").Shape;
const HitRecord = @import("hitRecord.zig").HitRecord;
const u32Rand = @import("main.zig").u32Rand;
const sort = std.sort.sort;

const Hittable = union(enum) {
    shape: *Shape,
    bvh: BvhNode,

    pub fn hit(self: Hittable, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        switch(self) {
            .shape => return self.shape.hit(ray, t_min, t_max, rec),
            .bvh =>  return self.bvh.hit(ray, t_min, t_max, rec),
        }
    }

    pub fn bounding(self: Hittable, timeStart: f64, timeEnd: f64) BoundingBox {
        return switch(self) {
            .shape => self.shape.bounding(timeStart, timeEnd),
            .bvh => self.bvh.bounding(timeStart, timeEnd),
        };
    }
};

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

pub const BvhNode = struct {
    left: *Hittable,
    right: *Hittable,
    box: BoundingBox,

    pub fn init(timeStart: f64, timeEnd: f64, list: *HittableList) BvhNode {
        return initSlice(timeStart, timeEnd, 0, @intCast(u32,list.objects.items.len), list);
    }

    fn initSlice(timeStart: f64, timeEnd: f64, start: u32, end: u32, list: *HittableList) BvhNode {
        const axis = u32Rand(2);
        const span = end - start;
        var relem: *Hittable = undefined;
        var lelem: *Hittable = undefined;

        switch(span) {
            1 => {
                const elem = &Hittable{.shape = &list.objects.items[start]};
                return BvhNode {.left = elem, .right = elem, .box = elem.bounding(timeStart, timeEnd)};
            },
            2 => {
                if(compareBoxes(list.objects.items[start], list.objects.items[start+1], axis)){
                    relem = &Hittable{.shape = &list.objects.items[start]};
                    lelem = &Hittable{.shape = &list.objects.items[start+1]};
                } else {
                    relem = &Hittable{.shape = &list.objects.items[start+1]};
                    lelem = &Hittable{.shape = &list.objects.items[start]};
                }
            },
            else => {
                switch(axis) {
                    0 => sort(Shape, list.objects.items[start..end], {}, generateXComparator()),
                    1 => sort(Shape, list.objects.items[start..end], {}, generateYComparator()),
                    2 => sort(Shape, list.objects.items[start..end], {}, generateZComparator()), 
                    else => unreachable
                }
                const mid = start + span/2;
                lelem = &Hittable {.bvh = initSlice(timeStart, timeEnd, start, mid, list)};
                relem = &Hittable {.bvh = initSlice(timeStart, timeEnd, mid, end, list)};
            }
        }
        return BvhNode {.left = lelem, .right = relem, .box = lelem.bounding(timeStart, timeEnd).surroundingBox(relem.bounding(timeStart, timeEnd))};
    }

    pub fn hit(self: BvhNode, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        const hit_left = self.left.hit(ray, t_min, t_max, rec);
        const hit_right = self.right.hit(ray, t_min, if(hit_left) rec.t else t_max, rec);
        return self.box.hit(ray, t_min, t_max) and (hit_left or hit_right);
    }

    pub fn bounding(self: BvhNode, timeStart: f64, timeEnd: f64) BoundingBox {
        _ = timeStart - timeEnd;
        return self.box;
    }
};