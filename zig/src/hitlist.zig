const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const HitRecord = @import("hitRecord.zig").HitRecord;
const Shape = @import("shapes.zig").Shape;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const ArrayList = std.ArrayList(Shape);
const Allocator = std.mem.Allocator;
const Point = Vec3.init;    

const ListErr = error{NegativeIndex, OutOfBounds, IncorrectIndices};

pub const HittableList = struct {

    objects: ArrayList,

    pub fn init(all: Allocator) HittableList {
        return HittableList{.objects = ArrayList.init(all)};
    }

    pub fn addShape (self: *HittableList, object: Shape) !void {
        try add(self, object);
    }

    fn add(self: *HittableList, object: Shape) !void {
        try self.*.objects.append(object);
    }

    pub fn clear(self: HittableList) void {
        self.objects.clearAndFree();
    }

    pub fn destroy(self: HittableList) void {
        self.objects.deinit();
    } 

    pub fn length(self: HittableList) usize {
        return self.objects.items.len;
    }

    pub fn hit(self: HittableList, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        //std.debug.print("List.hit", .{});
        var temp_rec = HitRecord.init();
        var rec_pointer: *HitRecord = &temp_rec;
        var hit_anything: bool = false;
        var closest = t_max;
        for (self.objects.items) |object| {
            if (object.hit(ray, t_min, t_max, rec_pointer)) {
                if(temp_rec.t > closest) continue;
                hit_anything = true;
                closest = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }

    pub fn bounding(self: HittableList, timeStart: f64, timeEnd: f64, start: u32, end: u32) BoundingBox {
        //if(self.objects.items.len <= end or self.objects.items.len <= start) return ListErr.OutOfBounds;
        //if(start < 0 or end < 0) return ListErr.NegativeIndex;
        //if(end < start) return ListErr.IncorrectIndices;

        var temp_box: BoundingBox = undefined;
        var first_box = true;

        for (start..end) |i| {
            const shape = self.objects.items[i].shape;
            if (first_box) {
                temp_box = shape.bounding(timeStart, timeEnd);
                first_box = false;
            } else {
                temp_box = temp_box.surroundingBox(shape.bounding(timeStart, timeEnd));
            }
        }
        return temp_box;
    }
};