const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const HittableList = @import("hitlist.zig").HittableList;
const Sphere = @import("sphere.zig").Sphere;
const Camera = @import("camera.zig").Camera;
const Material = @import("materials.zig").Material;
const c = @cImport({@cInclude("SDL2.h");});
const point = Vec3.init;
const black = Vec3.init(0,0,0);
const RndGen = std.rand.DefaultPrng;
const time = std.time;

var rand = RndGen.init(0);

pub fn floatRand(min: f64, max: f64) f64 {
    return min + (max - min) * rand.random().float(f64);
}

fn randomScene(scene: *HittableList) !void {
    // Add floor
    const material_ground = Material.makeLambertian(Vec3.init(0.5, 0.5, 0.5));
    try scene.*.add(Sphere.init(.{ 0, -1000.0,  0}, 1000.0, material_ground));  

    var a: i64 = -11;
    while (a < 11):(a+=1) {
        var b: i64 = -11;
        while (b < 11):(b+=1) {
            
            const choose_mat = floatRand(0,1);
            const center = point(
                @intToFloat(f64, a) + 0.9*floatRand(0, 1),
                0.2,
                @intToFloat(f64, b) + 0.9*floatRand(0, 1),
                );
            if(Vec3.length(center - point(4, 0.2, 0)) > 0.9) {
                var sphere_material: Material = undefined;

                if(choose_mat < 0.8) {
                    // Diffuse
                    const albedo = Vec3.random(0, 1) * Vec3.random(0, 1);
                    sphere_material = Material.makeLambertian(albedo);
                    try scene.*.add(Sphere.init(center, 0.2, sphere_material));
                } else if (choose_mat < 0.95) {
                    // Metal 
                    const albedo = Vec3.random(0.5, 1) * Vec3.random(0.5, 1);
                    var fuzz = floatRand(0, 0.5);
                    sphere_material = Material.makeMetal(albedo, fuzz);
                    try scene.*.add(Sphere.init(center, 0.2, sphere_material));
                } else {
                    // glass
                    sphere_material = Material.makeDialectric(1.5);
                    try scene.*.add(Sphere.init(center, 0.2, sphere_material));
                }
            }
        }
    }

    const dialectric_mat = Material.makeDialectric(1.5);
    const lambertian_mat = Material.makeLambertian(point(0.4, 0.2, 0.1));
    const metal_mat = Material.makeMetal(point(0.7, 0.6, 0.5), 0.0);

    try scene.*.add(Sphere.init(point(-4,1,0), 1.0, lambertian_mat));
    try scene.*.add(Sphere.init(point(0,1,0), 1.0, dialectric_mat));
    try scene.*.add(Sphere.init(point(4,1,0), 1.0, metal_mat));
}

pub fn main() !void {

    // Image specs
    const aspect_ratio = 3.0/2.0;
    const width = 1200;
    const height = @floatToInt(usize, (@intToFloat(f64, width) / aspect_ratio));
    const samples = 50; 
    const max_depth = 50;

    // Render & Utils
    var file = try std.fs.cwd().createFile("output.ppm",  .{});
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{width, height});
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);
    const window = c.SDL_CreateWindow("Awesome Raytracer", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, width, height, c.SDL_WINDOW_SHOWN);
    const renderer = c.SDL_CreateRenderer(window, -1, 0);
    defer c.SDL_DestroyWindow(window);
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_Quit();
    rand = RndGen.init(@intCast(u64, time.nanoTimestamp()));

    // World Initialization
    // This Allocator is needed for the ArrayList in HittableList, since Zig otherwise can't deal with lists that grow in size easily
    var alloc = std.heap.page_allocator;
    var scene = HittableList.init(alloc);
    defer scene.destroy(); // Defer this to happen at the closing bracket of the main functionWS
    try randomScene(&scene);

    // Camera
    const lookfrom = point(13, 2, 3);
    const lookat = point(0, 0, 0);
    const vup = Vec3.init(0, 1, 0);
    const focus_dist: f64 = 10.0;
    const aperture: f64 = 0.1;
    var cam = Camera.init(lookfrom, lookat, vup, 20, aspect_ratio, aperture, focus_dist);

    // Main loop
    var row = height;
    while (row > 0):(row -= 1) {
        for (0..width) |col| {


            var pixel_color = black;
            for (0..samples) |_| {
                const u = (@intToFloat(f64, col)+floatRand(0,1))/@intToFloat(f64, width-1);
                const v = (@intToFloat(f64, row)+floatRand(0,1))/@intToFloat(f64, height-1);
                const r = cam.getRay(u, v);
                pixel_color += Ray.rayColor(r, &scene, max_depth);
            }
           //try color.renderColor(file.writer(), pixel_color, samples);
           try color.renderColor(renderer, file.writer(), pixel_color, samples, col, height - row);
        }
        _ = c.SDL_RenderPresent(renderer);
    }
    c.SDL_Delay(10000);
}

