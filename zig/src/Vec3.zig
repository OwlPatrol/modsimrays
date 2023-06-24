const std = @import("std");
pub const Vec3 = @Vector(3, f64);
const floatRand = @import("main.zig").floatRand;


/// Constructor for a Vec3
pub fn init(x: f64, y: f64, z: f64) Vec3 {
    return Vec3 {
        x,
        y,
        z,
    };
}

pub fn random(min:f64, max:f64) Vec3 {
    return Vec3 {
        floatRand(min, max),
        floatRand(min, max),
        floatRand(min, max),
    };
}

pub fn randomInUnitSphere() Vec3 {
    const r = floatRand(0, 1);
    const theta = floatRand(0, 1)*2*std.math.pi;
    const phi = floatRand(0, 1)*std.math.pi;
    return init(r*@cos(theta)*@sin(phi), r*@sin(theta)*@sin(phi), r*@cos(phi));
}

pub fn randomUnitVector() Vec3 {
    return normalize(randomInUnitSphere());
}

pub fn randomInHemisphere(normal: Vec3) Vec3 {
    const in_unit_sphere: Vec3 = randomInUnitSphere();
    if(dot(in_unit_sphere, normal)>0) return in_unit_sphere;
    return -in_unit_sphere;
}
pub fn randomUnitVectorInHemisphere(normal: Vec3) Vec3 {
    const random_direction = randomUnitVector();
    if(dot(random_direction, normal) > 0.0) return random_direction;
    return -random_direction;
}

pub fn randomInUnitDisc() Vec3 {
    const r = floatRand(0, 1);
    const theta = floatRand(0, 1)*2*std.math.pi;
    return init(r*@cos(theta), r*@sin(theta), 0);
}

pub fn norm (self: Vec3) f64 {
    return @reduce(.Add, self*self);
}

pub fn length (self: Vec3) f64 {
    return @sqrt(@reduce(.Add, self*self));
}

pub fn normalize (self: Vec3) Vec3 {
    return scalar(self, 1/length(self));
}

/// Implementation of dot product handling
pub fn dot(self: Vec3, other: Vec3) f64 {
    return @reduce(.Add, self*other);
}

/// Naive asf cross product function.
pub fn cross(self: Vec3, other: Vec3) Vec3 {
    return Vec3 {
        self[1] * other[2] - self[2] * other[1],
        self[2] * other[0] - self[0] * other[2],
        self[0] * other[1] - self[1] * other[0],
    };
}

/// Cheaty way to hopefully do scalar multiplication using SIMD
pub fn scalar(self: Vec3, num: f64) Vec3 {
    return self * @splat(3, num);
}

pub fn div(self: Vec3, num: f64) Vec3 {
    return self * @splat(3, 1/num);
}

pub fn toInt(comptime T: type, self: Vec3) @Vector(3, T) {
    return .{@floatToInt(T, self[0]), @floatToInt(T, self[1]), @floatToInt(T, self[2])};
}

pub fn nearZero(self: Vec3) bool {
    const s: f64 = 1e-8;
    return  @fabs(self[0]) > s and @fabs(self[1]) > s and @fabs(self[2]) > s;
}

pub fn reflect(v: Vec3, n: Vec3) Vec3 { // Potential issue
    return v - scalar(n, 2 * dot(v,n)); 
}

pub fn refract(unit_vector: Vec3, normal: Vec3, etai_over_etat: f64) Vec3 {
    const cos_theta = @min(dot(-unit_vector, normal), 1.0);
    const out_perp: Vec3 = @splat(3, etai_over_etat)*(normal*@splat(3, cos_theta) + unit_vector);
    const out_parallel: Vec3 = scalar(normal, -@sqrt(@fabs(1 - norm(out_perp))));
    return out_perp + out_parallel;
}
