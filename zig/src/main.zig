const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const Color = @import("writeColor.zig");
const HittableList = @import("hitlist.zig").HittableList;
const Shape = @import("shapes.zig").Shape;
const Bvh = @import("bvh.zig").Tree;
const Camera = @import("camera.zig").Camera;
const Material = @import("materials.zig").Material;
const Texture = @import("texture.zig").Texture;
const Utils = @import("utils.zig");
const Point = @Vector(3, f64);
const point = Vec3.init;
const page = std.heap.page_allocator;

pub fn main() !void {
    // Image specs
    const aspect_ratio = 9.0 / 16.0;
    const width = 400;
    const height = @as(usize, @intFromFloat((width * aspect_ratio)));
    const samples = 10;
    const max_depth = 10;


    // Render & Utils
    // Output the .ppm file
    var file = try std.fs.cwd().createFile("output.ppm", .{});
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{ width, height });

    // Data structure Utils
    var alloc = std.heap.page_allocator;
    var temp = HittableList.init(alloc);
    var scene = HittableList.init(alloc);
    defer temp.destroy();
    defer scene.destroy();

   // Camera Values
    var look_from: Point = undefined;
    var look_at: Point = undefined;
    var vfov: f64 = 20.0;
    var aperture: f64 = 0.0;
    const vup = Vec3.init(0, 1, 0);
    const focus_dist: f64 = 10.0;

    // World Initialization and appropriate camera values
    switch(4) {
        1 => {
            try Utils.randomScene(&temp);
            look_from = point(13, 2, 3);
            look_at = point(0, 0, 0);
            vfov = 20.0;
            aperture = 0.1;
        },
        2 => {
            try Utils.twoSpheres(&temp);
            look_from = point(13, 2, 3);
            look_at = point(0, 0, 0);
            vfov = 20.0;
        },
        3 => {
            try Utils.twoPerlinSpheres(&temp);
            look_from = point(13,2,3);
            look_at = point(0,0,0);
            vfov = 20.0;
        },
        4 => {
            try Utils.earth(&temp);
            look_from = point(13,2,3);
            look_at = point(0,0,0);
            vfov = 20.0;
        },
        else => unreachable,
    }

    // Camera Initialization
    var cam = Camera.init(look_from, look_at, vup, vfov, aspect_ratio, aperture, focus_dist, 0.0, 1.0);

    // BVH Tree Initialization and list cleanup.
    var tree = try Bvh.init(0, 1, &temp);
    const tree_ptr = try page.create(Bvh);
    tree_ptr.* = tree;
    try scene.addTree(tree_ptr);
    defer tree.destroy();

    // Main loop
    for (0..height) |row| {
        //std.debug.print("There are {} rows left to render\n", .{height - row});
        for (0..width) |col| {
            var pixel_color = point(0, 0, 0);
            for (0..samples) |_| {
                const u: f64 = (@as(f64, @floatFromInt(col)) + Utils.floatRand(0, 1)) / @as(f64, @floatFromInt(width - 1));
                const v = (@as(f64, @floatFromInt(height - row)) + Utils.floatRand(0, 1)) / @as(f64, @floatFromInt(height - 1));
                const r = cam.getRay(u, v);
                //pixel_color += Ray.rayColorList(r, &scene, max_depth);
                pixel_color += Ray.rayColor(r, tree_ptr, max_depth);
            }
            try Color.renderColor(file.writer(), pixel_color, samples, col, height - row);
        }
    }
}
