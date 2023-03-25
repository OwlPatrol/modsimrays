const Vec3 = @import("vector.zig").Vec3;
const Ray = @import("rays.zig").Ray;

pub const Camera = struct {
    lower_left: Vec3,
    horizontal: Vec3,
    vertical: Vec3,
    origin: Vec3,

    pub fn init() Camera {
        return Camera {
            .lower_left = Vec3.init(-2.0, -1.0, -1.0),
            .horizontal = Vec3.init(4.0, 0.0, 0.0),
            .vertical = Vec3.init(0.0, 2.0, 0.0),
            .origin = Vec3.init(0.0, 0.0, 0.0),
        };
    }

    pub fn get_ray(self: Camera, u: f32, v: f32) Ray {
        return 
        Ray.init
        (
            self.origin, 
            self.lower_left + self.horizontal.scalar(u) + self.vertical.scalar(v) - self.origin
        );
    }
    
};