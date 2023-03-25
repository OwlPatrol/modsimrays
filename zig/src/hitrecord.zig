const Vec3 = @import("vector.zig").Vec3;

const HitRecord = struct {
    t: f32 = 0,
    p: Vec3 = Vec3,
    normal: Vec3 = Vec3
};