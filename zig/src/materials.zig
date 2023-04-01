const std = @import("std");
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig");

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,

    pub fn scatter(self:Material, ray_in: Ray, hit_rec: *HitRecord, attenuation: *@Vector(3, f32), scattered: *Ray) bool {
        switch(self) {
            .lambertian => return self.lambertian.scatter(ray_in, hit_rec, attenuation, scattered), // Could cause issues?
            .metal => return self.metal.scatter(ray_in, hit_rec, attenuation, scattered), // Could cause issues?
        }
    }

    pub fn makeLambertian(color: @Vector(3, f32)) Material {
        return Material {.lambertian = Lambertian.init(color)};
    }

    pub fn makeMetal(color:@Vector(3,f32)) Material {
        return Material {.metal = Metal.init(color)};
    }
};

const Lambertian = struct {
    albedo: @Vector(3, f32),

    fn init(color: @Vector(3, f32)) Lambertian {
        return Lambertian {.albedo = color};
    }

    fn scatter(self:Lambertian, ray_in: Ray, rec: *HitRecord, attenuation: *@Vector(3, f32), scattered: *Ray) bool {
    const scatter_direction = Vec3.normalize(rec.*.normal + Vec3.randomUnitVectorInHemisphere(rec.*.normal));
    scattered.* = Ray.init(rec.*.p, scatter_direction);
    attenuation.* = Vec3.scalar(self.albedo, Vec3.dot(rec.*.normal, scatter_direction));
    _ = ray_in;
    return true;
}

};

const Metal = struct {
    albedo: @Vector(3, f32),

    fn init(color: @Vector(3, f32)) Metal {
        return Metal {.albedo = color};
    }

    fn scatter(self:Metal, ray_in: Ray, rec: *HitRecord, attenuation: *@Vector(3, f32), scattered: *Ray) bool {
        const reflected = Vec3.reflect(Vec3.normalize(ray_in.dir), rec.*.normal);
        scattered.* = Ray.init(rec.*.p, reflected);
        attenuation.* = self.albedo;
        return Vec3.dot(scattered.*.dir, rec.*.normal) > 0;
    }
};