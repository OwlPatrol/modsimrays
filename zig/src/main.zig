const std = @import("std");
const print = std.debug.print;
const c = 
    @cImport({
        @cInclude("SDL.h");
        });
const RndGen = std.rand.DefaultPrng;
const Ray = @import("rays.zig").Ray;
const scene = @import("scene.zig").Scene;
const object = @import("object.zig");
const Vec3 = @import("vector.zig");
const Camera = @import("camera.zig").Camera;

pub fn main() !void {

    var rand = RndGen.init(0);
    const width: usize = 1680;
    const height: usize = 980;

    _ = c.SDL_Init(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("SDL2 Example", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, width, height, c.SDL_WINDOW_SHOWN);
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, 0);
    defer c.SDL_DestroyRenderer(renderer);

    // Samples per pixel
    const samples: usize = 100;
    const max_depth = 5;

    var cam = Camera.init();
    var sim_scene = scene {
        .object_list = .{ 
            object.Shape.init(@Vector(3, f32) {700, 300, 800}, 20), 
            object.Shape.init(@Vector(3, f32) {550, 720, 650}, 60),
                }
            };
    print("{}",.{sim_scene.object_list[1]});


    // ppm file gen
    var file = try std.fs.cwd().createFile("output.ppm",  .{});
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{width, height});

    const surface = c.SDL_CreateRGBSurface(0, width, height, 32, 0, 0, 0, 0);
    defer c.SDL_FreeSurface(surface);
    for (0..height) |row| {
        for (0..width) |col| {

            var color = Vec3.init(0,0,0);
            for (0..samples) |_| {
                var u: f32 = (@intToFloat(f32, col) + rand.random().float(f32)) / @intToFloat(f32, width);
                var v: f32 = (@intToFloat(f32, row) + rand.random().float(f32)) / @intToFloat(f32, height);
                var ray: Ray = cam.getRay(u, v);
                _ = ray.pointsAt(2.0); // Why?
                color = color + ray.color(sim_scene, max_depth);
            }

            color = Vec3.scalar(color, 1/@intToFloat(f32, samples));
            color = 
                @Vector(3, f32) {
                    @sqrt(color[0]),
                    @sqrt(color[1]),
                    @sqrt(color[2]),
                };
            var ir: u8 = @floatToInt(u8, 255.99*color[0]);
            var ig: u8 = @floatToInt(u8, 255.99*color[1]);
            var ib: u8 = @floatToInt(u8, 255.99*color[2]);

            _ = c.SDL_SetRenderDrawColor(renderer, ir, ig, ib, 255);
            _ = c.SDL_RenderDrawPoint(renderer, @intCast(c_int, col), @intCast(c_int,row));
        }
        _ = c.SDL_RenderPresent(renderer);
    }

    c.SDL_Delay(10000);

    _ = c.SDL_RenderReadPixels(renderer, c.SDL_PIXELFORMAT_ARGB8888, 0, surface.*.pixels, surface.*.pitch);
    _ = c.SDL_SaveBMP(surface, "image.bmp");
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}