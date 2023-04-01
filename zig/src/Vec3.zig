const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const Vec3 = @Vector(3, f32);
const time = std.time;

fn floatRand(min: f32, max: f32) f32 {
    var rand = RndGen.init(0);
    rand.seed(@intCast(u64, time.nanoTimestamp()));
    return min + (max - min) * rand.random().float(f32);
}

x: f32 = 0,
y: f32 = 0,
z: f32 = 0,

/// Constructor for a Vec3
pub fn init(x: f32, y: f32, z: f32) Vec3 {
    return Vec3 {
        x,
        y,
        z,
    };
}

pub fn random(min:f32, max:f32) Vec3 {
    return Vec3 {
        floatRand(min, max),
        floatRand(min, max),
        floatRand(min, max),
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

pub fn norm (self: Vec3) f32 {
    return self[0]*self[0] + self[1]*self[1] + self[2]*self[2];
}

pub fn length (self: Vec3) f32 {
    return @sqrt(norm(self));
}

pub fn normalize (self: Vec3) Vec3 {
    return div(self, length(self));
}

/// Implementation of dot product handling
pub fn dot(self: Vec3, other: Vec3) f32 {
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
pub fn scalar(self: Vec3, num: f32) Vec3 {
    return Vec3 {
        self[0] * num,
        self[1] * num,
        self[2] * num,            
    };
}

pub fn div(self: Vec3, num: f32) Vec3 {
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
    const s: f32 = 1e-8;
    return  @fabs(self[0]) > s and @fabs(self[1]) > s and @fabs(self[2]) > s;
}

pub fn reflect(v: Vec3, n: Vec3) Vec3 { // Potential issue
    return v - scalar(n, 2 * dot(v,n)); 
}

pub fn randomUnitVectorInHemisphere(normal: Vec3) Vec3 {
    const random_direction = randomUnitVector();
    if(dot(random_direction, normal) > 0.0) return random_direction;
    return -random_direction;
}