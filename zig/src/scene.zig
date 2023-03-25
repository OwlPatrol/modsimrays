const std = @import("std");
const rays = @import("rays.zig");
const Vec3 = @import("vector.zig").Vec3;
const Shape = @import("object.zig").Shape;
const HitRecord = @import("hitrecord.zig").HitRecord;
const Ray = rays.Ray;

var object_list: []Shape = {};

pub fn addObject(object:Shape) []Shape {
    object_list = []Shape {object} ++ object_list;
    return object_list;
}

fn hit(ray: Ray, t_min: f32, t_max: f32, hit_rec: *HitRecord) bool {
    var temp_rec: HitRecord = HitRecord{};
    var is_hit = false;
    var closest: f32 = t_max;

    for (object_list) |shape| {
        if(shape.hitShape(ray, t_min, closest, &temp_rec)) {
            is_hit = true;
            closest = temp_rec.t;
            hit_rec.* = temp_rec;
        }
    }

    return is_hit;
}


test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}