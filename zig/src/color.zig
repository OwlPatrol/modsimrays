const Vec3 = @import("Vec3.zig");
const std = @import("std");
const color = Vec3.init();
const c = 
    @cImport({
        @cInclude("SDL.h");
        });

//pub fn printColor(writer: anytype, col: @Vector(3, f64), samples: f64) !void {
//    var temp = Vec3.div(col, samples);
//    try writer.print("{} {} {}\n", .{@floatToInt(u8, multiSample(@sqrt(temp[0]))), @floatToInt(u8, multiSample(@sqrt(temp[1]))), @floatToInt(u8, multiSample(@sqrt(temp[2])))});
//}

pub fn renderColor(renderer: anytype, writer: anytype, col: @Vector(3, f64), samples: f64, x: usize, y: usize) !void {
    var scale = 1 / samples;
    var r = @floatToInt(u8, multiSample(col[0]*scale));
    var g = @floatToInt(u8, multiSample(col[1]*scale));
    var b = @floatToInt(u8, multiSample(col[2]*scale));
    try writer.print("{} {} {}\n", .{r, g, b});
    _ = c.SDL_SetRenderDrawColor(renderer, r, g, b, 255);
    _ = c.SDL_RenderDrawPoint(renderer, @intCast(c_int, x), @intCast(c_int,y));
}
//pub fn renderColor(writer: anytype, col: @Vector(3, f64), samples: f64) !void {
//    var scale = 1 / samples;
//    var r = @floatToInt(u8, multiSample(col[0]*scale));
//    var g = @floatToInt(u8, multiSample(col[1]*scale));
//    var b = @floatToInt(u8, multiSample(col[2]*scale));
//    try writer.print("{} {} {}\n", .{r, g, b});
//}

fn clamp(x: f64, min: f64, max: f64) f64 {
    if (x < min) return min;
    if (x > max) return max;
    return x;
}

fn multiSample(x: f64) f64 {
    return 256 * clamp(@sqrt(x), 0, 0.999);
}