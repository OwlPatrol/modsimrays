const std = @import("std");
const HittableList = @import("hitlist.zig").HittableList;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Ray = @import("ray.zig").Ray;
const Shape = @import("shapes.zig").Shape;
const ListElem = @import("hitlist.zig").ListElem;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Allocator = std.mem.Allocator;
const u32Rand = @import("utils.zig").u32Rand;
const sort = std.sort.heap;
const page = std.heap.page_allocator;

fn compareBoxes(a: *Shape, b: *Shape, axis: u32) bool {
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

    pub fn print(self: Node) void {
        switch(self) {
            .shape => |s| std.debug.print("leaf with shape: {}\n", .{s.*}),
            .tree => |t| t.*.print(),
        }
    }

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
    left: *Node,
    right: *Node,
    box: *BoundingBox,

    pub fn print(self: Tree) void {
        std.debug.print("Hi I'm a (sub)tree with this box: {}\n", .{self.box});
        self.left.print();
        self.right.print();
    }

    pub fn destroy(self: Tree) void {
        switch (self.left.*) {
            .tree => |t| {
                t.*.destroy();
                std.heap.page_allocator.destroy(t);
            },
            .shape => |s| s.destroy(),
        }
        switch (self.right.*) {
            .tree => |t| {
                t.*.destroy();
                std.heap.page_allocator.destroy(t);
            },
            else => std.debug.print("", .{}),
        }
    }

    pub fn count(self:Tree) usize {
        return switch(self.left){ .tree => |l| l.count(), else => 0} + switch(self.right){.tree => |r| r.count(), else => 0} + 1;
    }

    pub fn init(timeStart: f64, timeEnd: f64, hittable_list: *HittableList) !Tree {
        return try initSlice(timeStart, timeEnd, 0, @intCast(hittable_list.objects.items.len), hittable_list);
    }

    fn initSlice(timeStart: f64, timeEnd: f64, start: u32, end: u32, hittable_list: *HittableList) !Tree {
        const axis = u32Rand(2);
        const span = end - start;
        const leftptr = try page.create(Tree);
        const rightptr = try page.create(Tree);
        const relem = try page.create(Node);
        const lelem = try page.create(Node);
        const box_ptr = try page.create(BoundingBox);


        var left_tree: Tree = undefined;
        var right_tree: Tree = undefined;
        

        switch(span) {
            1 => {
                const nodeptr = try page.create(Node);
                const shapeptr = hittable_list.objects.items[start].shape;
                nodeptr.* = Node{.shape = shapeptr};
                box_ptr.* = nodeptr.*.bounding(timeStart, timeEnd);
                return Tree {.left = nodeptr, .right = nodeptr, .box = box_ptr};
            },
            2 => {
                const shape_left = try page.create(Shape);
                const shape_right = try page.create(Shape);
                if(compareBoxes(hittable_list.objects.items[start].shape, hittable_list.objects.items[start+1].shape, axis)){
                    shape_left.* = hittable_list.objects.items[start].shape.*;
                    shape_right.* = hittable_list.objects.items[start+1].shape.*;
                } else {
                    shape_left.* = hittable_list.objects.items[start+1].shape.*;
                    shape_right.* = hittable_list.objects.items[start].shape.*;
                }
                    lelem.* = Node{.shape = shape_left};
                    relem.* = Node{.shape = shape_right};
                box_ptr.* = relem.*.bounding(timeStart, timeEnd).surroundingBox(lelem.bounding(timeStart, timeEnd));
                return Tree {.left = lelem, .right = relem, .box = box_ptr};
            },
            else => {
                switch(axis) {
                    0 => sort(ListElem, hittable_list.objects.items[start..end], {}, generateXComparator()),
                    1 => sort(ListElem, hittable_list.objects.items[start..end], {}, generateYComparator()),
                    2 => sort(ListElem, hittable_list.objects.items[start..end], {}, generateZComparator()), 
                    else => unreachable
                }
                const mid = start + span/2;
                left_tree = try initSlice(timeStart, timeEnd, start, mid, hittable_list);
                right_tree = try initSlice(timeStart, timeEnd, mid, end, hittable_list);
                lelem.* = Node {.tree = leftptr};
                relem.* = Node{.tree = rightptr};
            }
        }
        leftptr.* = left_tree;
        rightptr.* = right_tree;
        box_ptr.* = left_tree.bounding(timeStart, timeEnd).surroundingBox(right_tree.bounding(timeStart, timeEnd));
        return Tree {.left = lelem, .right = relem, .box = box_ptr};
    }
    
    pub fn hit(self: Tree, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        if (!self.box.hit(ray, t_min, t_max)) return false;
        const hit_left = self.left.hit(ray, t_min, t_max, rec);
        var hit_right: bool = undefined;
        if (hit_left) {
            hit_right = self.right.hit(ray, t_min, rec.*.t, rec);
        } else {
            hit_right = self.right.hit(ray, t_min, t_max, rec);
        }
        return (hit_left or hit_right);
    }

    pub fn bounding(self: Tree, timeStart: f64, timeEnd: f64) BoundingBox {
        _ = timeStart - timeEnd;
        return self.box.*;
    }
};