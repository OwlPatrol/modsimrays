const std = @import("std");
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("Vec3.zig");
const Point = @Vector(3, f64);
const floatRand = @import("main.zig").floatRand;

pub const Camera = struct {
    origin: Point,
    lower_left: Point,
    horizontal: Point,
    vertical: Point,
    u: Point,
    v: Point,
    w: Point,
    lens_radius: f64,
    time0: f64,
    time1: f64,

    pub fn init(lookfrom: Point, lookat: Point, vup: Point, vfov: f64, aspect_ratio: f64, aperture: f64, focus_dist: f64, time0: f64, time1: f64) Camera {
        const theta = std.math.degreesToRadians(f64, vfov);
        const h = @tan(theta / 2);
        const height = 2.0 * h;
        const width = aspect_ratio * height;

        const w = Vec3.normalize(lookfrom - lookat);
        const u = Vec3.normalize(Vec3.cross(vup, w));
        const v = Vec3.cross(w, u);

        const origin = lookfrom;
        const horizontal = Vec3.scalar(u, focus_dist * width);
        const vertical = Vec3.scalar(v, focus_dist * height);
        const lower_left = origin - Vec3.div(horizontal, 2) - Vec3.div(vertical, 2) - Vec3.scalar(w, focus_dist);

        const lens_radius = aperture / 2;

        return Camera{ .origin = origin, .lower_left = lower_left, .horizontal = horizontal, .vertical = vertical, .u = u, .v = v, .w = w, .lens_radius = lens_radius, .time0 = time0, .time1 = time1 };
    }

    pub fn getRay(self: Camera, s: f64, t: f64) Ray {
        const rd = Vec3.scalar(Vec3.randomInUnitDisc(), self.lens_radius);
        const offset = Vec3.scalar(self.u, rd[0]) + Vec3.scalar(self.v, rd[1]);
        return Ray.init(self.origin + offset, self.lower_left + Vec3.scalar(self.horizontal, s) + Vec3.scalar(self.vertical, t) - self.origin - offset, floatRand(self.time0, self.time1));
    }
};
