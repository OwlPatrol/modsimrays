
const Vec3 = @import("vector.zig");

const Ray = @import("rays.zig").Ray;
const Vec3 = @Vector(3, f32);

pub const Camera = struct {
    lower_left: @Vector(3,f32),
    horizontal: @Vector(3,f32),
    vertical: @Vector(3,f32),
    origin: @Vector(3,f32),

    pub fn init() Camera {
        return Camera {
            .lower_left = Vec.init(-16/9, -1.0, -1.0),
            .horizontal = Vec.init(32.0 / 9.0, 0.0, 0.0),
            .vertical = Vec.init(0.0, 2.0, 0.0),
            .origin = Vec.init(0.0, 0.0, 0.0),
        };
    }

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
    }
    
};