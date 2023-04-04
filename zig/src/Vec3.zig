const std = @import("std");
pub const Vec3 = @Vector(3, f64);
const main = @import("main.zig");


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
        main.floatRand(min, max),
        main.floatRand(min, max),
        main.floatRand(min, max),
    };
}

pub fn randomInUnitSphere() Vec3 {
    var p = random(-1, 1);
    while (length(p) >= 1) p = random(-1, 1);
    return p;
}

pub fn randomUnitVector() Vec3 {
    return normalize(random(-1,1));
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
    while (true) {
        var p = init(main.floatRand(-1, 1), main.floatRand(-1,1), 0);
        if(norm(p) >= 1) continue;
        return p;
    }
}

pub fn norm (self: Vec3) f64 {
    return dot(self, self);
}

pub fn length (self: Vec3) f64 {
    return @sqrt(norm(self));
}

pub fn normalize (self: Vec3) Vec3 {
    return scalar(self, 1/length(self));
}

/// Implementation of dot product handling
pub fn dot(self: Vec3, other: Vec3) f64 {
    return self[0] * other[0] + self[1] * other[1] + self[2] * other[2];
}

/// Naive asf cross product function.
pub fn cross(self: Vec3, other: Vec3) Vec3 {
    return Vec3 {
        self[1] * other[2] - self[2] * other[1],
        self[2] * other[0] - self[0] * other[2],
        self[0] * other[1] - self[1] * other[0],
    };
}

/// Scalar Multiplication doesn't exist in zig, who knew? 
/// We need it tho.
pub fn scalar(self: Vec3, num: f64) Vec3 {
    return Vec3 {
        self[0] * num,
        self[1] * num,
        self[2] * num,            
    };
}

pub fn div(self: Vec3, num: f64) Vec3 {
    return Vec3 {
        self[0] / num,
        self[1] / num,
        self[2] / num,
    };
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
    const out_perp: Vec3 = scalar(scalar(normal, cos_theta) + unit_vector, etai_over_etat);
    const out_parallel: Vec3 = scalar(normal, -@sqrt(@fabs(1 - norm(out_perp))));
    return out_perp + out_parallel;
}
