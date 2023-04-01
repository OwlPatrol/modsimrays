const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const HitRecord = @import("hitRecord.zig").HitRecord;
const HittableList = @import("hitlist.zig").HittableList;
const Sphere = @import("sphere.zig").Sphere;
const RndGen = std.rand.DefaultPrng;
const Camera = @import("camera.zig").Camera;
const Material = @import("materials.zig").Material;
const c = @cImport({@cInclude("SDL.h");});
const point = Vec3.init;
const black = Vec3.init(0,0,0);
const zeroVec = black;

fn floatRand() f32 {
    var rand = RndGen.init(0);
    return rand.random().float(f32);
}

fn floatRandRange(min: f32, max: f32) f32 {
    return min + (max-min)*floatRand();
}

fn rayColor(ray: Ray, scene: *HittableList, depth: usize) @Vector(3, f32) {
    if(depth <= 0) return black;

    var rec = HitRecord.init();
    if(scene.hit(ray, 0.001, std.math.floatMax(f32), &rec)) {
        var scattered = Ray.init(zeroVec, zeroVec); // ??????
        var attenuation = black;
        if(rec.material.scatter(ray, &rec, &attenuation, &scattered))
            return attenuation*rayColor(scattered, scene, depth - 1);
        return black;
        // const target = rec.p + rec.normal + Vec3.randomInHemisphere(rec.normal);
        // return Vec3.scalar(rayColor(Ray.init(rec.p, target - rec.p), scene, depth - 1), 0.5);
    } 
    const unit_dir = Vec3.normalize(ray.dir);
    var t = 0.5 * (unit_dir[1] + 1);
    return Vec3.scalar(Vec3.init(1,1,1), (1 - t)) + Vec3.scalar(Vec3.init(0.5, 0.7, 1.0), t);
}

pub fn main() !void {
    // Image specs
    const aspect_ratio = 16.0/9.0;
    const width = 1000;
    const height = @floatToInt(usize, (@intToFloat(f32, width) / aspect_ratio));
    const samples = 200; 
    const max_depth = 100;

    // World Initialization
    // This Allocator is needed for the ArrayList in HittableList, since Zig otherwise can't deal with lists that grow in size easily
    var alloc = std.heap.page_allocator;
    var scene = HittableList.init(alloc);
    defer scene.destroy(); // Defer this to happen at the closing bracket of the main functionWS


    // Initialize the values for the materials. 
    const material_ground = Material.makeLambertian(Vec3.init(0.8, 0.8, 0.0));
    const material_center = Material.makeDialectric(1.5);
    const material_left   = Material.makeDialectric(1.5);
    const material_right  = Material.makeMetal(Vec3.init(0.8, 0.6, 0.2), 1.0);
    // Place the objects. Since they are equally far away from the camera on the z-axis it's important that we place the one we want closest to us last in the list.
    try scene.add(Sphere.init(.{0, -100.5,  -1},    100, material_ground));
    try scene.add(Sphere.init(.{-1, 0,      -1},    0.5, material_left));
    try scene.add(Sphere.init(.{1,  0,      -1},    0.5, material_right));
    try scene.add(Sphere.init(.{0,  0,      -1},    0.5, material_center));

    // Camera
    var cam = Camera.init();

    // Render & Utils
    var file = try std.fs.cwd().createFile("output.ppm",  .{});
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{width, height});
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();
    const window = c.SDL_CreateWindow("Awesome Raytracer", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, width, height, c.SDL_WINDOW_SHOWN);
    defer c.SDL_DestroyWindow(window);
    const renderer = c.SDL_CreateRenderer(window, -1, 0);
    defer c.SDL_DestroyRenderer(renderer);
   
    // Main loop
    var row = height;
    while (row > 0):(row -= 1) {
        for (0..width) |col| {


            var pixel_color = black;
            for (0..samples) |_| {
                const u = (@intToFloat(f32, col)+floatRand())/@intToFloat(f32, width-1);
                const v = (@intToFloat(f32, row)+floatRand())/@intToFloat(f32, height-1);
                const r = cam.getRay(u, v);
                pixel_color += rayColor(r, &scene, max_depth);
            }
           try color.renderColor(renderer, file.writer(), pixel_color, samples, col, height - row);
        }
        _ = c.SDL_RenderPresent(renderer);
    }
    c.SDL_Delay(10000);
}

