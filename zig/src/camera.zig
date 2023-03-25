const Vec3 = @import("vector.zig").Vec3;

const Camera = struct {
    lower_left: Vec3,
    horizontal: Vec3,
    vertical: Vec3,
    origin: Vec3,
};