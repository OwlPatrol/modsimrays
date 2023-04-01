const Vec3 = @import("Vec3.zig");
const std = @import("std");
const color = Vec3.init();
const c = 
    @cImport({
        @cInclude("SDL.h");
        });

//pub fn printColor(writer: anytype, col: @Vector(3, f32), samples: f32) !void {
//    var temp = Vec3.div(col, samples);
//    try writer.print("{} {} {}\n", .{@floatToInt(u8, multiSample(@sqrt(temp[0]))), @floatToInt(u8, multiSample(@sqrt(temp[1]))), @floatToInt(u8, multiSample(@sqrt(temp[2])))});
//}

pub fn printColor(writer: anytype, col: @Vector(3, f32), samples: f32) !void {
    var scale = 1 / samples;
    var r = @floatToInt(u8, multiSample(col[0]*scale));
    var g = @floatToInt(u8, multiSample(col[1]*scale));
    var b = @floatToInt(u8, multiSample(col[2]*scale));
    try writer.print("{} {} {}\n", .{r, g, b});
}

pub fn renderColor(renderer: anytype, col: @Vector(3, f32), samples: f32, x: usize, y: usize) !void {
    var scale = 1 / samples;
    var r = @floatToInt(u8, multiSample(col[0]*scale));
    var g = @floatToInt(u8, multiSample(col[1]*scale));
    var b = @floatToInt(u8, multiSample(col[2]*scale));
    _ = c.SDL_SetRenderDrawColor(renderer, r, g, b, 255);
    _ = c.SDL_RenderDrawPoint(renderer, @intCast(c_int, x), @intCast(c_int,y));
}

fn clamp(x: f32, min: f32, max: f32) f32 {
    if (x < min) return min;
    if (x > max) return max;
    return x;
}

fn multiSample(x: f32) f32 {
    return 256 * clamp(@sqrt(x), 0, 0.999);
}