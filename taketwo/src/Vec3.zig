const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const Vec3 = @Vector(3, f32);

fn floatRand() f32 {
    var rand = RndGen.init(0);
    var x = rand.random().float(f32);
    return if (rand.random().boolean()) x else - x; 
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

pub fn random() Vec3 {
    return Vec3 {
        floatRand(),
        floatRand(),
        floatRand(),
    };
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