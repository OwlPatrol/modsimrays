const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const HitRecord = @import("hitRecord.zig").HitRecord;
const HittableList = @import("hitlist.zig").HittableList;
const Sphere = @import("sphere.zig").Sphere;
const RndGen = std.rand.DefaultPrng;
const Camera = @import("camera.zig").Camera;
const point = Vec3.init;
const black = Vec3.init(0,0,0);

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
    if(scene.hit(ray, 0, std.math.floatMax(f32), &rec)) {
        const target = rec.p + rec.normal + Vec3.randomUnitVector();
        return Vec3.scalar(rayColor(Ray.init(rec.p, target - rec.p), scene, depth - 1), 0.5);
    } 
    const unit_dir = Vec3.normalize(ray.dir);
    var t = 0.5 * (unit_dir[1] + 1);
    return Vec3.scalar(Vec3.init(1,1,1), (1 - t)) + Vec3.scalar(Vec3.init(0.5, 0.7, 1.0), t);
}

pub fn main() !void {
    // Image
    const aspect_ratio = 16.0/9.0;
    const width = 1000;
    const height = @floatToInt(usize, (@intToFloat(f32, width) / aspect_ratio));
    const samples = 50; 
    const max_depth = 20;

    // World
    // Allocator needed for the ArrayList
    var alloc = std.heap.page_allocator;
    var scene = HittableList.init(alloc);
    defer scene.destroy();
    try scene.add(Sphere.init(.{0, -100.5, -1.0}, 100));
    try scene.add(Sphere.init(.{0, 0, -1}, 0.5));
    //std.debug.print("{}", .{scene.objects});

    // Camera
    var cam = Camera.init();

    // Render & Utils
    var file = try std.fs.cwd().createFile("output.ppm",  .{});
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{width, height});

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
            try color.printColor(file.writer(), pixel_color, samples);
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
