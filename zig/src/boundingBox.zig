/// Code for Axis Aligned Bounding Boxes
/// 
/// 
/// 
const std = @import("std");
const Point = @Vector(3, f64);
const Ray = @import("ray.zig").Ray;

pub const BoundingBox = struct {
    min: Point,
    max: Point,

    pub fn _hit(self: BoundingBox, ray: Ray, t_min: f64, t_max: f64) bool {
        for (0..3) |a| {
            const t0 = @min((self.min[a] - ray.origin[a]) / ray.dir[a], (self.max[a] - ray.origin[a]) / ray.dir[a]);
            const t1 = @max((self.min[a] - ray.origin[a]) / ray.dir[a], (self.max[a] - ray.origin[a]) / ray.dir[a]);
            const min = @max(t0, t_min);
            const max = @min(t1, t_max);
            if(max <= min) return false;
        }
        return true;
    }

    pub fn hit(self: BoundingBox, ray: Ray, t_min: f64, t_max: f64) bool {
        for (0..3) |a| {
            const invD = 1.0 / ray.dir[a];
            var t0 = invD * (self.min[a] - ray.origin[a]);
            var t1 = invD * (self.max[a] - ray.origin[a]);
            if(invD < 0) {
                const temp = t0;
                t0 = t1;
                t1 = temp;
            }
            const min = @max(t0, t_min);
            const max = @min(t1, t_max);
            if(max <= min) return false;
        }
        return true;
    }

    pub fn surroundingBox(box0: BoundingBox, box1: BoundingBox) BoundingBox {
        const small = @min(box0.min, box1.min);
        const big = @max(box0.max, box1.max);
        return BoundingBox {.min = small, .max = big};
    }
};