const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const point = Vec3.init;

fn rayColor(ray: Ray) @Vector(3, f32) {
    var t = hitSphere(point(0, 0, -1), 0.5, ray);
    if(t > 0.0) {
        const n = Vec3.normalize(ray.at(t) - point(0, 0, -1));
        return Vec3.scalar(n + point(1, 1, 1), 0.5);
    } else {
        const unit_dir = Vec3.div(ray.dir, Vec3.length(ray.dir));
        t = 0.5 * (-unit_dir[1] + 1);
        return Vec3.scalar(Vec3.init(1,1,1), (1 - t)) + Vec3.scalar(Vec3.init(0.5, 0.7, 1.0), t);
    }
}

pub fn main() !void {
    // Image
    const aspect_ratio = 16.0/9.0;
    const width = 400;
    const height = @as(usize, (@intToFloat(f32, width) / aspect_ratio));

    // Camera
    const viewport_height = 2.0;
    const viewport_width = aspect_ratio * viewport_height;
    const focal_length = 1.0;

    const origin = point(0, 0, 0);
    const horizontal = Vec3.init(viewport_width, 0, 0);
    const vertical = Vec3.init(0, viewport_height, 0);
    const lower_left_corner = origin - Vec3.div(horizontal, 2) - Vec3.div(vertical, 2) - Vec3.init(0, 0, focal_length);

    // Render
    var file = try std.fs.cwd().createFile("output.ppm",  .{});
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{width, height});

    for (0..height) |row| {
        for (0..width) |col| {
            const u = @intToFloat(f32, col)/@intToFloat(f32, width);
            const v = @intToFloat(f32, row)/@intToFloat(f32, height);
            const r = Ray.init(origin, lower_left_corner + Vec3.scalar(horizontal,u) + Vec3.scalar(vertical, v) - origin);
            try color.printColor(file.writer(), rayColor(r));
        }
    }

}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
