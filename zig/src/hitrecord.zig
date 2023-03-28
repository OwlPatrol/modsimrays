const Vec3 = @import("vector.zig");

pub const HitRecord = struct {
    t: f32 = 0,
    p: @Vector(3,f32) = Vec3.init(0,0,0),
    normal: @Vector(3,f32) = Vec3.init(0,0,0),
};