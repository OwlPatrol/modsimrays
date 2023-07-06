const std = @import("std");
const Vec3 = @import("Vec3.zig");
const clamp = @import("utils.zig").clamp;
const epsilon = std.math.floatEps;

pub fn renderColor(writer: anytype, col: @Vector(3, f64), samples: f64, x: usize, y: usize) !void {
    var scale = 1 / samples;
    var r:u8 = @intFromFloat(multiSample(col[0]*scale));
    var g:u8 = @intFromFloat(multiSample(col[1]*scale));
    var b:u8 = @intFromFloat(multiSample(col[2]*scale));
    try writer.print("{} {} {}\n", .{r, g, b});
    _ = x + y;
}

fn multiSample(x: f64) f64 {
    return 256 * clamp(@sqrt(x), 0, 1 - epsilon(f64));
}