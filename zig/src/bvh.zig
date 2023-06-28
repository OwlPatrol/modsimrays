const std = @import("std");
const HittableList = @import("hitlist.zig").HittableList;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Ray = @import("ray.zig").Ray;
const Shape = @import("shapes.zig").Shape;
const ListElem = @import("hitlist.zig").ListElem;
const HitRecord = @import("hitRecord.zig").HitRecord;
const u32Rand = @import("main.zig").u32Rand;
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

const Node = union(enum) {
    shape: *Shape,
    tree: *Tree,

    pub fn hit(self: Node, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        return switch(self) {
            .shape => |s| s.hit(ray, t_min, t_max, rec),
            .tree => |t| t.hit(ray, t_min, t_max, rec),
        };   
    }

    pub fn bounding(self: Node, timeStart: f64, timeEnd: f64) BoundingBox {
        return switch(self) {
            .shape => |s| s.bounding(timeStart, timeEnd),
            .tree => |t| t.bounding(timeStart, timeEnd),
        };   
    }
};

pub const Tree = struct {
    left: Node,
    right: Node,
    box: BoundingBox,

    pub fn init(timeStart: f64, timeEnd: f64, list: *HittableList) Tree {
        return initSlice(timeStart, timeEnd, 0, @intCast(u32,list.objects.items.len), list);
    }

    fn initSlice(timeStart: f64, timeEnd: f64, start: u32, end: u32, list: *HittableList) Tree {
        const axis = u32Rand(2);
        const span = end - start;
        var left_tree: Tree = undefined;
        var right_tree: Tree = undefined;
        var box: BoundingBox = undefined;

        switch(span) {
            1 => {
                const elem = Node{.shape = &list.objects.items[start].shape};
                return Tree {.left = elem, .right = elem, .box = elem.bounding(timeStart, timeEnd)};
            },
            2 => {
                var relem: Node = undefined;
                var lelem: Node = undefined;
                if(compareBoxes(list.objects.items[start].shape, list.objects.items[start+1].shape, axis)){
                    relem = Node{.shape = &list.objects.items[start].shape};
                    lelem = Node{.shape = &list.objects.items[start+1].shape};
                } else {
                    relem = Node{.shape = &list.objects.items[start+1].shape};
                    lelem = Node{.shape = &list.objects.items[start].shape};
                }
                box = relem.bounding(timeStart, timeEnd).surroundingBox(lelem.bounding(timeStart, timeEnd));
                return Tree {.left = lelem, .right = relem, .box = box};
            },
            else => {
                switch(axis) {
                    0 => sort(ListElem, list.objects.items[start..end], {}, generateXComparator()),
                    1 => sort(ListElem, list.objects.items[start..end], {}, generateYComparator()),
                    2 => sort(ListElem, list.objects.items[start..end], {}, generateZComparator()), 
                    else => unreachable
                }
                const mid = start + span/2;
                left_tree = initSlice(timeStart, timeEnd, start, mid, list);
                right_tree = initSlice(timeStart, timeEnd, mid, end, list);
            }
        }
        return Tree {.left = Node {.tree = &left_tree}, .right = Node{.tree = &right_tree}, .box = left_tree.bounding(timeStart, timeEnd).surroundingBox(right_tree.bounding(timeStart, timeEnd))};
    }
    
    pub fn hit(self: Tree, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        if (!self.box.hit(ray, t_min, t_max)) return false;
        const hit_left = self.left.hit(ray, t_min, t_max, rec);
        const hit_right = self.right.hit(ray, t_min, if(hit_left) rec.t else t_max, rec);
        return (hit_left or hit_right);
    }

    pub fn bounding(self: Tree, timeStart: f64, timeEnd: f64) BoundingBox {
        _ = timeStart - timeEnd;
        return self.box;
    }
};