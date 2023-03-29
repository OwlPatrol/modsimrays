const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const HitRecord = @import("hitRecord.zig").HitRecord;
const Sphere = @import("sphere.zig").Sphere;
const point = Vec3.init;    
const ArrayList = std.ArrayList(Sphere);
const Allocator = std.mem.Allocator;

pub const HittableList = struct {

    objects: ArrayList,

    pub fn init(all: Allocator) HittableList {
        return HittableList{.objects = ArrayList.init(all)};
    }

    pub fn add(self: *HittableList, object: Sphere) !void {
        try self.*.objects.append(object);
    }

    pub fn clear(self: HittableList) void {
        self.objects.clearAndFree();
    }

    pub fn destroy(self: HittableList) void {
        self.objects.deinit();
    } 

    pub fn hit(self:HittableList, ray: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        var temp_rec = HitRecord.init();
        var recpointer: *HitRecord = &temp_rec;
        var hit_anything: bool = false;
        var closest = t_max;

        for (self.objects.allocatedSlice()) |object| {
            if (object.hit(ray, t_min, t_max, recpointer)) {
                hit_anything = true;
                closest = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }
};