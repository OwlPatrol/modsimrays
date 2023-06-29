const std = @import("std");
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig");
const Texture = @import("texture.zig").Texture;
const floatRand = @import("utils.zig").floatRand;
 const page = std.heap.page_allocator;

/// Tagged union representing the abstract idea of a material. Can only hold a value in one field at a time.
pub const Material = union(enum) {
    lambertian: *Lambertian,
    metal: *Metal,
    dialectric: *Dialectric,

    /// Generalized scatter() function. Will call the relevant scatter function depending on what material it is
    pub fn scatter(self: Material, ray_in: Ray, hit_rec: *HitRecord, attenuation: *@Vector(3, f64), scattered: *Ray) bool {
        return switch (self) {
            .lambertian => |l| l.scatter(ray_in, hit_rec, attenuation, scattered),
            .metal => |m| m.scatter(ray_in, hit_rec, attenuation, scattered),
            .dialectric => |d| d.scatter(ray_in, hit_rec, attenuation, scattered),
        };
    }

    //pub fn destroy(self: *Material) void {
    //    switch(self.*) {
    //        .lambertian => |l| {
    //            l.destroy();
    //        },
    //        .metal => |m| {
    //            m.destroy();
    //        },
    //        .dialectric => |d| {
    //            page.destroy(d);
    //        }
    //    }
    //    page.destroy(self);
    //}

    pub fn makeLambertian(color: @Vector(3, f64)) !*Material {
        const mat_ptr = try page.create(Material);
        mat_ptr.* = Material{ .lambertian = try Lambertian.init(color)};
        return mat_ptr;
    }

    pub fn texturedLambertian(texture: *Texture) !*Material {
        const mat_ptr = try page.create(Material);
        mat_ptr.* = Material{ .lambertian = try Lambertian.initTextured(texture)};
        return mat_ptr;
    }

    pub fn makeMetal(color: @Vector(3, f64), f: f64) !*Material {
        const mat_ptr = try page.create(Material);
        mat_ptr.* = Material{ .metal = try Metal.init(color, f) };
        return mat_ptr;
    }

    pub fn makeDialectric(refraction_index: f64) !*Material {
        const mat_ptr = try page.create(Material);
        const dia_ptr = try page.create(Dialectric);
        dia_ptr.* = Dialectric{ .refraction_index = refraction_index };
        mat_ptr.* = Material{ .dialectric = dia_ptr};
        return mat_ptr;
    }
};

const Lambertian = struct {
    albedo: *Texture,

    fn init(color: @Vector(3, f64)) !*Lambertian {
        const ptr = try page.create(Lambertian);
        ptr.* = Lambertian{ .albedo = try Texture.solidColor(color[0], color[1], color[2]) };
        return ptr;
    }

    //fn destroy(self: Lambertian) void {
        //self.albedo.destroy();
    //    page.destroy(self);
    //}

    fn initTextured(texture: *Texture) !*Lambertian {
        const ptr = try page.create(Lambertian);
        ptr.* = Lambertian{.albedo = texture};
        return ptr;
    }

    fn scatter(self: Lambertian, ray_in: Ray, rec: *HitRecord, attenuation: *@Vector(3, f64), scattered: *Ray) bool {
        const scatter_direction = Vec3.normalize(rec.*.normal + Vec3.randomUnitVectorInHemisphere(rec.*.normal));
        scattered.* = Ray.init(rec.*.p, scatter_direction, ray_in.time);
        attenuation.* = self.albedo.value(rec.*.u, rec.*.v, rec.*.p);
        return true;
    }
};

const Metal = struct {
    albedo: @Vector(3, f64),
    fuzz: f64,

    fn init(color: @Vector(3, f64), f: f64) !*Metal {
        const ptr = try page.create(Metal);
        ptr.* = Metal{ .albedo = color, .fuzz = if (f < 1) f else 1 };
        return ptr;
    }

    fn destroy(self: *Metal) void {
        page.destroy(self);
    }

    fn scatter(self: Metal, ray_in: Ray, rec: *HitRecord, attenuation: *@Vector(3, f64), scattered: *Ray) bool {
        const reflected = Vec3.reflect(Vec3.normalize(ray_in.dir), rec.*.normal);
        scattered.* = Ray.init(rec.*.p, reflected + Vec3.scalar(Vec3.randomInUnitSphere(), self.fuzz), ray_in.time);
        attenuation.* = self.albedo;
        return Vec3.dot(scattered.*.dir, rec.*.normal) > 0;
    }
};

const Dialectric = struct {
    refraction_index: f64,

    fn scatter(self: Dialectric, ray_in: Ray, rec: *HitRecord, attenuation: *@Vector(3, f64), scattered: *Ray) bool {
        const refraction_ratio: f64 = if (rec.*.front_face) 1.0 / self.refraction_index else self.refraction_index;
        const unit_dir = Vec3.normalize(ray_in.dir);
        const cos_theta = @min(Vec3.dot(-unit_dir, rec.*.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract: bool = refraction_ratio * sin_theta > 1.0;
        var direction = @splat(3, @as(f64, 0));

        if (cannot_refract or reflectance(cos_theta, refraction_ratio) > floatRand(0, 1.0)) {
            direction = Vec3.reflect(unit_dir, rec.*.normal);
        } else {
            direction = Vec3.refract(unit_dir, Vec3.normalize(rec.*.normal), refraction_ratio);
        }

        attenuation.* = @splat(3, @as(f64, 1.0));
        scattered.* = Ray.init(rec.*.p, direction, ray_in.time);
        return true;
    }

    fn reflectance(cosine: f64, ref_idx: f64) f64 {
        var r0 = (1.0 - ref_idx) / (1.0 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, 1.0 - cosine, 5.0);
    }
};

