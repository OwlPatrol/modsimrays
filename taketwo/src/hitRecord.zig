const std = @import("std");

const HitRecord = struct {
    p: @Vector(3, f32),
    normal: @Vector(3, f32),
    t: f32,
};