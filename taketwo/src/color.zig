const Vec3 = @import("Vec3.zig");
const std = @import("std");
const color = Vec3.init();

pub fn printColor(writer: anytype, col: @Vector(3, f32)) !void {
    const temp = Vec3.scalar(col, 255.99);
    std.debug.print("{}\n", .{temp});

    try writer.print("{} {} {}\n", .{@floatToInt(u8, temp[0]), @floatToInt(u8, temp[1]), @floatToInt(u8, temp[2])});
}