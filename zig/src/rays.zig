const std = @import("std");
const rand = std.rand.Random;
const Scene = @import("scene.zig");
const Vec3 = @import("vector.zig").Vec3;
const HitRecord = @import("hitrecord.zig");


fn floatRand() f32 {
    var x = rand.float();
    return if (rand.boolean()) x else - x; 
}

const black: Vec3 = .{0, 0, 0};

/// A Ray has a direction vector and a starting point.
const Ray = struct {
    // From where it's going
    origin: Vec3, 
    // Direction the ray is going
    dir: Vec3,
    
    // Where it ends up
    pub fn pointsAt(self: Vec3, t:f32) Vec3 {
        return self.dir.scalar(t) + self.origin; // May need to use @Vector here
    }

    pub fn color(self: Ray, scene: Scene, depth: usize) Vec3 {
        var hit_rec: HitRecord = HitRecord{};
        if (depth == 0) return black;
        if (scene.hit(self, scene)) {
            const target: Vec3 = hit_rec.p + hit_rec.normal + Vec3.random;
            return color(Ray{hit_rec.p, target - hit_rec.p}, scene, depth - 1);
        } else {
            var unit_dir: Vec3 = self.direction.normalize();
            var t: f32 = 0.5 * (unit_dir.y + 1.0);
            return; return (Vec3 {1, 1, 1}).scalar(1 - t) + (Vec3{0.5, 0.7, 1.0}).scalar(t);
        }
    }
};


test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}