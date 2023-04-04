
const std = @import("std");
const Ray = @import("ray.zig").Ray;
const vector = @import("Vec3.zig");
const Vec3 = vector.Vec3;
const Point = @Vector(3, f64);


pub const Camera = struct {
    pub const Self = @This();
    origin: Vec3,
    lower_left: Vec3,
    horizontal: Vec3,
    vertical: Vec3,
    u: Vec3,
    v: Vec3,
    w: Vec3,
    lens_radius: f64,

    pub fn init(lookfrom: Point, lookat: Point, vup: Vec3, vfov: f64, aspect_ratio: f64, aperture: f64, focus_dist: f64) Camera {
        const theta = std.math.degreesToRadians(f64, vfov);
        const h = @tan(theta / 2);
        const height = 2.0 * h;
        const width = aspect_ratio * height;

        const w = vector.normalize(lookfrom-lookat);
        const u = vector.normalize(vector.cross(vup, w));
        const v = vector.cross(w, u);

        const origin = lookfrom;
        const horizontal = vector.scalar(u, focus_dist*width);
        const vertical = vector.scalar(v, focus_dist*height);
        const lower_left = origin - vector.div(horizontal, 2) - vector.div(vertical, 2) - vector.scalar(w, focus_dist);

        const lens_radius = aperture/2;

        return Camera { .origin = origin, .lower_left = lower_left, .horizontal = horizontal, .vertical = vertical, .u = u, .v = v, .w = w,  .lens_radius = lens_radius };
    }

    pub fn getRay(self: Camera, s: f64, t: f64) Ray {
        const rd = vector.scalar(vector.randomInUnitDisc(), self.lens_radius);
        const offset = vector.scalar(self.u, rd[0]) + vector.scalar(self.v, rd[1]);
        return Ray.init(
            self.origin + offset, 
            self.lower_left
            + vector.scalar(self.horizontal, s) 
            + vector.scalar(self.vertical, t) 
            - self.origin
            - offset
            );
    }
};