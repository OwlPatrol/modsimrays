const Vec3 = @import("vector.zig").Vec3;

pub fn isBetween(n: f32, max:f32, min: f32) bool {
    return if (n < min) false else if (n > max) false else true;
}

const Shape = union {
    sphere: Sphere,
    cube: Cube,

    fn hitShape(self: Shape, ray :Ray, t_min: f32, t_max: f32, hit_rec: HitRecord) bool {
        switch(self) {
            .sphere => return hitSphere(.sphere),
            .cube => return hitCube(.cube)
        }
    }
};

const Sphere = struct {
    center: Vec3,
    radius: f32,

    pub fn init(center: Vec3, radius: f32) Sphere{
        .center = center;
        .radius = radius;
    }

    fn hitSphere(self: Sphere, ray :Ray, t_min: f32, t_max: f32, hit_rec: *HitRecord) bool {
        const oc: Vec3 = ray.origin - self.center;
        const a = ray.dir.norm();
        const b = - oc.dot(ray.dir);
        const c = oc.norm() - self.radius * self.radius;
        const discriminant = b*b - a*c;
        if (discriminant > 0) {
            temp = (b - @sqrt(discriminant)) / a;
            if (isBetween(temp ,t_min, t_max)) {
                hit_rec.*.t = temp;
                hit_rec.*.p = ray.pointsAt(temp);
                hit_rec.*.normal = (hit_rec.*.p - self.center).scalar(1 / self.radius);
                return true;
            }
            temp = (b + @sqrt(discriminant)) / a;
            if (isBetween(temp, t_min, t_max)) {
                hit_rec.*.t = temp;
                hit_rec.*.p = ray.pointsAt(temp);
                hit_rec.*.normal = (hit_rec.*.p - self.center).scalar(1 / self.radius);
                return true;
            }
        }
        return false;
    }
};

const Cube = struct {
    origin: Vec3,
    length: f32,

    pub fn init(center: Vec3, len: f32) Cube {
        .center = center;
        .length = len;

    }

    fn hit(self: Cube, ray: Ray) bool {
        // TODO: Implement this!
        return false;
    }
};