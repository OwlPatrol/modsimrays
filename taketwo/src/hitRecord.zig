const std = @import("std");
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("Vec3.zig");

pub const HitRecord = struct {
    p: @Vector(3, f32),
    normal: @Vector(3, f32),
    t: f32,
    front_face: bool,

    pub fn init() HitRecord {
        return HitRecord {
            .p = Vec3.init(0, 0, 0),
            .normal = Vec3.init(0, 0, 0),
            .t = 0,
            .front_face = true,
        };
    }

    pub fn set_face_normal(self: *HitRecord, ray: Ray, out_normal: @Vector(3, f32)) void {
        self.*.front_face = Vec3.dot(ray.dir, out_normal) < 0;
        self.*.normal = if (self.front_face) out_normal else -out_normal; 
    }
};