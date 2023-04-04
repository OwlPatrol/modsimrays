<<<<<<< HEAD
const std = @import("std");
const Ray = @import("ray.zig").Ray;
const vector = @import("Vec3.zig");
const Vec3 = vector.Vec3;
const Point = @Vector(3, f64);

=======

const Vec3 = @import("vector.zig");

const Ray = @import("rays.zig").Ray;
const Vec3 = @Vector(3, f32);
>>>>>>> 6c2ecc8d6e2afa26fb3f3ed7d293d33d593a88e0

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

<<<<<<< HEAD
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
=======
    pub fn getRay(self: Camera, u: f32, v: f32) Ray {
        return 
        Ray.init
        (
            self.origin,      
            self.lower_left 
            + Vec3.scalar(self.horizontal, u) 
            + Vec3.scalar(self.vertical, v) 
            - self.origin

        );
>>>>>>> 6c2ecc8d6e2afa26fb3f3ed7d293d33d593a88e0
    }
};