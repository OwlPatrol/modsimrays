const std = @import("std");
const Vec3 = @import("Vec3.zig");
const HitRecord = @import("hitRecord.zig").HitRecord;
const HittableList = @import("hitlist.zig").HittableList;
const Bvh = @import("bvh.zig").Tree;
const black = Vec3.init(0, 0, 0);
const zeroVec = black;

pub const Ray = struct {
    origin: @Vector(3, f64),
    dir: @Vector(3, f64),
    time: f64,

    pub fn init(origin: @Vector(3, f64), dir: @Vector(3, f64), time: f64) Ray {
        return Ray{
            .origin = origin,
            .dir = dir,
            .time = time,
        };
    }

    pub fn at(self: Ray, t: f64) @Vector(3, f64) {
        return self.origin + Vec3.scalar(self.dir, t);
    }

    pub fn rayColor(ray: Ray, scene: *Bvh, depth: usize) @Vector(3, f64) {
        if (depth <= 0) return black;

        var rec = HitRecord.init();
        if (scene.hit(ray, 0.001, std.math.floatMax(f64), &rec)) {
            var scattered = Ray.init(zeroVec, zeroVec, 0);
            var attenuation = black;
            if (rec.material.scatter(ray, &rec, &attenuation, &scattered))
                return attenuation * rayColor(scattered, scene, depth - 1);
            return black;
        }
        const unit_dir = Vec3.normalize(ray.dir);
        var t = 0.5 * (unit_dir[1] + 1);
        return Vec3.scalar(Vec3.init(1, 1, 1), (1 - t)) + Vec3.scalar(Vec3.init(0.5, 0.7, 1.0), t);
    }

    pub fn rayColorList(ray: Ray, scene: *HittableList, depth: usize) @Vector(3, f64) {
        if (depth <= 0) return black;

        var rec = HitRecord.init();
        if (scene.hit(ray, 0.001, std.math.floatMax(f64), &rec)) {
            var scattered = Ray.init(zeroVec, zeroVec, 0);
            var attenuation = black;
            if (rec.material.scatter(ray, &rec, &attenuation, &scattered))
                return attenuation * rayColorList(scattered, scene, depth - 1);
            return black;
        }
        const unit_dir = Vec3.normalize(ray.dir);
        var t = 0.5 * (unit_dir[1] + 1);
        return Vec3.scalar(Vec3.init(1, 1, 1), (1 - t)) + Vec3.scalar(Vec3.init(0.5, 0.7, 1.0), t);
    }
};
