const std = @import("std");
const print = std.debug.print;
const Scene = @import("scene.zig").Scene;
const Vec3 = @import("vector.zig");
const HitRecord = @import("hitrecord.zig").HitRecord;

<<<<<<< HEAD:zig/src/not-used/rays.zig
const black = @Vector(3,f32){0,0,0};
=======

const black = Vec3.init(0, 0, 0);

>>>>>>> 6c2ecc8d6e2afa26fb3f3ed7d293d33d593a88e0:zig/src/rays.zig

/// A Ray has a direction vector and a starting point.
pub const Ray = struct {
    // From where it's going
    origin: @Vector(3, f32), 
    // Direction the ray is going
    dir: @Vector(3, f32),
    
    pub fn init(origin: @Vector(3, f32), dir: @Vector(3, f32)) Ray {
        return Ray {
            .origin = origin,
            .dir = dir,
        };
    }

    // Where it ends up
    pub fn pointsAt(self: Ray, t:f32) @Vector(3,f32) {
        return Vec3.scalar(self.dir, t) + self.origin;
    }

    pub fn color(self: Ray, scene: Scene, depth: usize) @Vector(3,f32) {
        var hit_rec = HitRecord{.t = 0, .p = black, .normal = black};
        if (depth == 0) return black;
        if (scene.hit(self, 0.001, std.math.floatMax(f32), &hit_rec)) {
            const target: @Vector(3, f32) = hit_rec.p + hit_rec.normal + Vec3.random();
            var sus = Vec3.scalar(color(Ray.init(hit_rec.p, (target - hit_rec.p)), scene, depth - 1), 0.5);
            print("Hit\n", .{});
            return sus;
        } else {
            print("No hit", .{});
            var unit_dir: @Vector(3, f32) = Vec3.normalize(self.dir);
            var t: f32 = 0.5 * (unit_dir[1] + 1.0);
<<<<<<< HEAD:zig/src/not-used/rays.zig
            return Vec3.scalar(Vec3.init(1, 1, 1), 1 - t) + Vec3.scalar(Vec3.init(0.5, 0.7, 1.0), t);
=======
            return Vec3.scalar(Vec3.init(0, 0, 0), 1 - t) + Vec3.scalar(Vec3.init(0.5, 0.7, 1.0), t);
>>>>>>> 6c2ecc8d6e2afa26fb3f3ed7d293d33d593a88e0:zig/src/rays.zig
        }
    }
};


test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}