const std = @import("std");
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("Vec3.zig");
const Point = @Vector(3, f32);

const aspectRatio = 16.0 / 9.0;
const height = 2.0;
const width = height * aspectRatio;
const focal_length = 1;

const orig = Vec3.init(0, 0, 0);
const horiz = Vec3.init(width, 0, 0);
const vert = Vec3.init(0, height, 0);
const low_left = orig - Vec3.div(horiz, 2) - Vec3.div(vert, 2) - Vec3.init(0, 0, focal_length);

pub const Camera = struct {
    origin: @Vector(3, f32),
    horizontal: @Vector(3, f32),
    vertical: @Vector(3, f32),
    lower_left: @Vector(3, f32),

    pub fn init() Camera {
        return Camera{
            .origin = orig,
            .horizontal = horiz,
            .vertical = vert,
            .lower_left = low_left,
        };
    }

    pub fn getRay(self: Camera, u: f32, v: f32) Ray {
        return Ray.init(
            self.origin, 
            self.lower_left 
            + Vec3.scalar(self.horizontal, u) 
            + Vec3.scalar(self.vertical, v) 
            - self.origin
            );
    }
};