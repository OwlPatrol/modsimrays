const Vec3 = @import("Vec3.zig");
const std = @import("std");
const c = 
    @cImport({
        @cInclude("SDL.h");
        });

pub fn renderColor(writer: anytype, col: @Vector(3, f64), samples: f64, x: usize, y: usize) !void {
    var scale = 1 / samples;
    var r = @floatToInt(u8, multiSample(col[0]*scale));
    var g = @floatToInt(u8, multiSample(col[1]*scale));
    var b = @floatToInt(u8, multiSample(col[2]*scale));
    try writer.print("{} {} {}\n", .{r, g, b});
    _ = x + y;  
    //_ = c.SDL_SetRenderDrawColor(renderer, r, g, b, 255);
    //_ = c.SDL_RenderDrawPoint(renderer, @intCast(c_int, x), @intCast(c_int,y));
}

fn clamp(x: f64, min: f64, max: f64) f64 {
    if (x < min) return min;
    if (x > max) return max;
    return x;
}

fn multiSample(x: f64) f64 {
    return 256 * clamp(@sqrt(x), 0, 0.999);
}