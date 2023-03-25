const std = @import("std");
const print = std.debug.print;
const c = 
    @cImport({
        @cInclude("raylib.h");
        @cInclude("<iostream>");
        });
const RndGen = std.rand.DefaultPrng;
const Ray = @import("rays.zig").Ray;
const scene = @import("scene.zig");
const object = @import("object.zig");
const Vec3 = @import("vector.zig").Vec3;
const Camera = @import("camera.zig").Camera;

pub fn main() !void {
    
    var rand = RndGen.init(0);
    const width: usize = 1000;
    const height: usize = 500;
    // Samples per pixel
    const samples: usize = 100;
    const max_depth = 50;

    var cam = Camera.init();
    var sim_scene = scene {};

    print("P3\n{} \n255\n{}", .{width, height});

    for (0..height) |row| {
        for (0..width) |col| {
            var color = Vec3 {};
            for (0..samples) |_| {
                var u: f32 = (@intToFloat(f32, col) + rand.random().float(f32)) / @intToFloat(f32, width);
                var v: f32 = (@intToFloat(f32, row) + rand.random().float(f32)) / @intToFloat(f32, height);
                var ray: Ray = cam.get_ray(u, v);
                //_ = ray.point_at(2.0); // Why?
                var color_vec: @Vector(3, f32) = color;
                var add_vec: @Vector(3, f32) = ray.color(sim_scene, max_depth);
                color_vec += add_vec;
                color = Vec3.init(color_vec[0], color_vec[1], color_vec[2]);
            }

            color.scalar(1/@intToFloat(f32, samples));
            color = Vec3{@sqrt(color.x), @sqrt(color.y),@sqrt(color.z)};
            var ir: usize = @floatToInt(usize, 255.99*color.x);
            var ig: usize = @floatToInt(usize, 255.99*color.y);
            var ib: usize = @floatToInt(usize, 255.99*color.z);

            print("{} {} {}\n", .{ir, ig, ib});
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}