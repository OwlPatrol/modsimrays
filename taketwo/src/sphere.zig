const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const point = Vec3.init;


pub const Sphere = struct {
    center: @Vector(3, f32),
    radius: f32,

    pub fn init(center: @Vector(3, f32), radius: f32) Sphere  {
        return Sphere {.center = center, .radius = radius};
    }

    pub fn hit(self: Sphere, ray: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        const oc = ray.origin - self.center;
        const a = Vec3.norm(ray.dir);
        const b = Vec3.dot(oc, ray.dir);
        const c = Vec3.norm(oc) - self.radius*self.radius;
        
        const discriminant =  b*b - a*c;
        if(discriminant < 0) return false;
        var sqrtd = @sqrt(discriminant);

        var root = (-b - sqrtd) / a;
        if (root < t_min or t_max < root) {
            root = sqrtd - b;
            if (root < t_min or t_max < root) return false;
        }
        rec.*.t = root;
        rec.*.p = ray.at(rec.*.t);
        var out_normal = Vec3.div((rec.*.p - self.center), self.radius);
        rec.set_face_normal(ray, out_normal);
        return true;
    }
};