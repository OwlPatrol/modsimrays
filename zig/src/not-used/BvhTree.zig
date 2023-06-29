const std = @import("std");
const Shape = @import("shapes.zig").Shape;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const HittableList = @import("hitlist.zig").HittableList;
const ListElem = @import("hitlist.zig").ListElem;
const uintRand = @import("utils.zig").u32Rand;
const sort = std.sort.sort;


fn compareBoxes(a: Shape, b: Shape, axis: u32) bool {
    return a.bounding(0, 0).min[axis] < b.bounding(0, 0).min[axis];
}

fn generateXComparator () fn (void, ListElem, ListElem) bool {
    return struct {
        pub fn inner(_: void, a: ListElem, b: ListElem) bool {
            return compareBoxes(a.shape, b.shape, 0);
        }
    }.inner;
}

fn generateYComparator() fn (void, ListElem, ListElem) bool {
    return struct {
        pub fn inner(_: void, a: ListElem, b: ListElem) bool {
            return compareBoxes(a.shape, b.shape, 1); 
        }
    }.inner;
}

fn generateZComparator () fn (void, ListElem, ListElem) bool {
    return struct {
        pub fn inner(_: void, a: ListElem, b: ListElem) bool {
            return compareBoxes(a.shape, b.shape, 2); 
        }
    }.inner;
}

pub const Tree = union(enum) {
    node: BvhNode,
    leaf: *Shape,

    pub fn hit(self: Tree, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        switch(self) {
            .leaf => return self.leaf.*.hit(ray, t_min, t_max, rec),
            .node => return self.node.hit(ray, t_min, t_max, rec),
        }
    }

    pub fn init(timeStart: f64, timeEnd: f64, start: u32, end: u32, list: *HittableList) *Tree {
        const span = end - start;
        const axis = uintRand(2);
        var slice = list.objects.items[start..end];

        if(span == 1) return &Tree {.leaf = &list.*.objects.items[start].shape};
        if(span == 2){ 
            var shape0 = list.*.objects.items[start].shape;
            var shape1 = list.*.objects.items[start+1].shape;
            var is_smaller = compareBoxes(shape0, shape1, axis);
            return &Tree {
                .node = BvhNode {
                    .left = &Tree {.leaf = if(is_smaller) &shape0 else &shape1,},
                    .right = &Tree {.leaf = if(is_smaller) &shape1 else &shape0,},
                    .box = list.*.objects.items[start].shape.bounding(timeStart, timeEnd).surroundingBox(list.*.objects.items[start+1].shape.bounding(timeStart, timeEnd)),
                },
            };
        }
        const mid = start + span/2;
        switch(axis) {
            0 => sort(ListElem, slice, {}, generateXComparator()),
            1 => sort(ListElem, slice, {}, generateYComparator()),
            2 => sort(ListElem, slice, {}, generateZComparator()),
            else => unreachable,
        }

        return &Tree {
            .node = BvhNode {
                .left = init(timeStart, timeEnd, start, mid, list),
                .right = init(timeStart, timeEnd, mid, end, list),
                .box = list.bounding(timeStart, timeEnd, start, end),
            }
        };
    }
};

const BvhNode = struct {
    left: *Tree,
    right: *Tree,
    box: BoundingBox,

    pub fn hit(self: BvhNode, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        if(!self.box.hit(ray, t_min, t_max)) return false;
        return self.left.*.hit(ray, t_min, t_max, rec) or self.right.*.hit(ray, t_min, t_max, rec);
    }
};