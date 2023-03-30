const Vec3 = @import("Vec3.zig");
const std = @import("std");
const color = Vec3.init();

pub fn printColor(writer: anytype, col: @Vector(3, f32), samples: f32) !void {
    var temp = Vec3.div(col, samples);
    try writer.print("{} {} {}\n", .{@floatToInt(u8, multiSample(temp[0])), @floatToInt(u8, multiSample(temp[1])), @floatToInt(u8, multiSample(temp[2]))});
}

fn clamp(x: f32, min: f32, max: f32) f32 {
    if (x < min) return min;
    if (x > max) return max;
    return x;
}

fn multiSample(x: f32) f32 {
    return 256 * clamp(x, 0, 0.999);
}