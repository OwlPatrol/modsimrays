const Vec3 = @import("vector.zig");

pub const HitRecord = struct {
    t: f64 = 0,
    p: @Vector(3,f64) = Vec3.init(0,0,0),
    normal: @Vector(3,f64) = Vec3.init(0,0,0),
};