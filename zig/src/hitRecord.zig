const std = @import("std");
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("Vec3.zig");
const Material = @import("materials.zig").Material;

pub const HitRecord = struct {
    p: @Vector(3, f64),
    normal: @Vector(3, f64),
    material: Material, // Could become issue
    t: f64,
    u: f64,
    v: f64,
    front_face: bool,

    pub fn init() HitRecord {
        return HitRecord {
            .p = Vec3.init(0, 0, 0),
            .normal = Vec3.init(0, 0, 0),
            .material = undefined,
            .t = 0,
            .u = 0,
            .v = 0,
            .front_face = true,
        };
    }

    pub fn lowerT(self: HitRecord, other: HitRecord) HitRecord {
        if (other.t < self.t) return other;
        return self;
    }

    pub fn setFaceNormal(self: *HitRecord, ray: Ray, out_normal: @Vector(3, f64)) void {
        self.*.front_face = Vec3.dot(ray.dir, out_normal) < 0;
        self.*.normal = if (self.front_face) out_normal else -out_normal; 
    }
};