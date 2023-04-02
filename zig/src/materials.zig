const std = @import("std");
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig");
const utils = @import("utils.zig");

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dialectric: Dialectric,

    pub fn scatter(self:Material, ray_in: Ray, hit_rec: *HitRecord, attenuation: *@Vector(3, f32), scattered: *Ray) bool {
        switch(self) {
            .lambertian => return self.lambertian.scatter(ray_in, hit_rec, attenuation, scattered),
            .metal => return self.metal.scatter(ray_in, hit_rec, attenuation, scattered),
            .dialectric => return self.dialectric.scatter(ray_in, hit_rec, attenuation, scattered),
        }
    }

    pub fn makeLambertian(color: @Vector(3, f32)) Material {
        return Material {.lambertian = Lambertian.init(color)};
    }

    pub fn makeMetal(color:@Vector(3,f32), f: f32) Material {
        return Material {.metal = Metal.init(color, f)};
    }

    pub fn makeDialectric(refraction_index: f32) Material {
        return Material { .dialectric = Dialectric {.refraction_index = refraction_index}};
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
    fuzz: f32,

    fn init(color: @Vector(3, f32), f: f32) Metal {
        return Metal {.albedo = color, .fuzz = if(f < 1) f else 1};
    }

    fn scatter(self:Metal, ray_in: Ray, rec: *HitRecord, attenuation: *@Vector(3, f32), scattered: *Ray) bool {
        const reflected = Vec3.reflect(Vec3.normalize(ray_in.dir), rec.*.normal);
        scattered.* = Ray.init(rec.*.p, reflected + Vec3.scalar(Vec3.randomInUnitSphere(), self.fuzz));
        attenuation.* = self.albedo;
        return Vec3.dot(scattered.*.dir, rec.*.normal) > 0;
    }
};

const Dialectric = struct {
    refraction_index: f32,

    fn scatter(self:Dialectric, ray_in: Ray, rec: *HitRecord, attenuation: *@Vector(3, f32), scattered: *Ray) bool {
        const refraction_ratio: f32 = if (rec.*.front_face) 1/self.refraction_index else self.refraction_index;
        const unit_dir = Vec3.normalize(ray_in.dir);
        const cos_theta  = @min(Vec3.dot(-unit_dir, rec.*.normal), 1);
        const sin_theta = @sqrt(1 - cos_theta*cos_theta);

        const cannot_refract: bool = refraction_ratio*sin_theta > 1.0;
        var direction = Vec3.init(0, 0, 0);

        if(cannot_refract or reflectance(cos_theta, refraction_ratio) > utils.floatRand(0, 1)){
            direction = Vec3.reflect(unit_dir, rec.*.normal);
        } else {
            direction = Vec3.refract(unit_dir, rec.*.normal, refraction_ratio);
        }


        attenuation.* = Vec3.init(1, 1, 1);
        scattered.* = Ray.init(rec.*.p, direction);
        return true;
    }    

    fn reflectance(cosine: f32, ref_idx: f32) f32 {
        var r0 = (1-ref_idx) / (1+ref_idx);
        r0 = r0*r0;
        return r0 + (1-r0)*std.math.pow(f32,(1 - cosine),5);
    }

};