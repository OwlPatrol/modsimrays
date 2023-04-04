const std = @import("std");
const rays = @import("rays.zig");
const Vec3 = @import("vector.zig");
const object = @import("object.zig");
const Shape = object.Shape;
const HitRecord = @import("hitrecord.zig").HitRecord;
const Ray = rays.Ray;

pub const Scene = struct {

    object_list: [2]object.Shape = undefined,

    pub fn addObject(self: Scene, thing:Shape) Scene {
        var new_list = [_]Shape {thing} ++ self.object_list;
        return Scene {.object_list = new_list};
    }

    pub fn hit(self: Scene, ray: Ray, t_min: f64, t_max: f64, hit_rec: *HitRecord) bool {
        var temp_rec: HitRecord = HitRecord{};
        var is_hit = false;
        var closest: f64 = t_max;

        for (self.object_list) |shape| {
            if(shape.hitShape(ray, t_min, closest, &temp_rec)) {
                is_hit = true;
                closest = temp_rec.t;
                hit_rec.* = temp_rec;
            }
        }

        return is_hit;
    }
};

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}