const std = @import("std");
const print = std.debug.print;
const c = 
    @cImport(
        @cInclude("raylib.h"),
        @cInclude("<iostream>"));
const rays = @import("rays.zig");
const scene = @import("scene.zig");
const object = @import("object.zig");
const vector = @import("vector.zig");
const hitrecord = @import("hitrecord.zig");
const camera = @import("camera.zig");

pub fn main() !void {
    const width: usize = 1000;
    const height: usize = 500;
    // Samples per pixel
    const samples: usize = 100;
    const max_depth = 50;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}