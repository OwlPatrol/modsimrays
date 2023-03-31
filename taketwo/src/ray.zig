const Vec3 = @import("Vec3.zig");


pub const Ray = struct {
    origin: @Vector(3, f32),
    dir: @Vector(3, f32),

    pub fn init(origin: @Vector(3, f32), dir: @Vector(3, f32)) Ray {
        return Ray {
            .origin = origin,
            .dir = dir,
        };
    }
    
    pub fn at(self:Ray, t: f32) @Vector(3, f32) {
        return self.origin + Vec3.scalar(self.dir, t);
    }
};