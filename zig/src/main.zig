const std = @import("std");
const print = std.debug.print;
const c = 
    @cImport(
        @cInclude("raylib.h"),
        @cInclude("<iostream>"));
const rays = @import("rays.zig");
const scen = @import("scene.zig");

pub fn main() !void {
    print("{}", .{"lol"});
}