const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const HitRecord = @import("hitRecord.zig").HitRecord;
const Shape = @import("shapes.zig").Shape;
const BoundingBox = @import("boundingBox.zig");
const ArrayList = std.ArrayList(Shape);
const Allocator = std.mem.Allocator;
const Point = Vec3.init;    

pub const HittableList = struct {

    objects: ArrayList,

    pub fn init(all: Allocator) HittableList {
        return HittableList{.objects = ArrayList.init(all)};
    }

    pub fn add(self: *HittableList, object: Shape) !void {
        try self.*.objects.append(object);
    }

    pub fn clear(self: HittableList) void {
        self.objects.clearAndFree();
    }

    pub fn destroy(self: HittableList) void {
        self.objects.deinit();
    } 

    pub fn hit(self: HittableList, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        var temp_rec = HitRecord.init();
        var recpointer: *HitRecord = &temp_rec;
        var hit_anything: bool = false;
        var closest = t_max;
        for (self.objects.items) |object| {
            if (object.hit(ray, t_min, t_max, recpointer)) {
                if(temp_rec.t > closest) continue;
                hit_anything = true;
                closest = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }

    pub fn boundingBox(self: HittableList, timeStart: f64, timeEnd: f64, box: *BoundingBox) bool {
        if(self.items.len == 0) return false;
        var temp_box: BoundingBox = undefined;
        var first_box = true;

        for (self.objects) |object| {
            if(!object.*.boundingBox(timeStart, timeEnd, temp_box)) return false;
            if (first_box) {
                box.*.min = temp_box.min;
                box.*.max = temp_box.max;
                first_box = false;
            } else {
                const surr = box.surroundingBox(temp_box);
                box.*.min = surr.min;
                box.*.max = surr.max;
            } 
        }

        return true;
    }
};