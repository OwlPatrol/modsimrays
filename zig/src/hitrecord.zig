const Vec3 = @import("vector.zig");
const Ray = @import("rays.zig").Ray;

pub const HitRecord = struct {
    t: f32 = 0,
    p: @Vector(3,f32) = Vec3.init(0,0,0),
    normal: @Vector(3,f32) = Vec3.init(0,0,0),
    front_face: bool = true,

    pub fn setFaceNormal(self: *HitRecord, ray: Ray, normal: @Vector(3, f32)) void {
        self.*.front_face = Vec3.dot(ray.dir, normal) < 0;
        self.*.normal = if(self.front_face) normal else -normal;
    }
};