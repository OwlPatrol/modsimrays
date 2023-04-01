const std = @import("std");
const RndGen = std.rand.DefaultPrng;

fn floatRand() f32 {
    var rand = RndGen.init(0);
    var x = rand.random().float(f32);
    return if (rand.random().boolean()) x else - x; 
}

    
/// Constructor for a @Vector(3, f32)
pub fn init(x: f32, y: f32, z: f32) @Vector(3, f32) {
    return @Vector(3, f32) {x, y, z};
}

pub fn random() @Vector(3, f32) {
    return @Vector(3, f32) {
        floatRand(),
        floatRand(),
        floatRand(),
    };
}

pub fn norm (self: @Vector(3, f32)) f32 {
    return @sqrt(dot(self, self));
}

pub fn normalize (self: @Vector(3, f32)) @Vector(3, f32) {
    const normal = norm(self);
    return  
        if(normal == 0) @Vector(3, f32) {0, 0, 0} 
        else scalar(self, 1 / normal);
}

/// Implementation of dot product handling
pub fn dot(self: @Vector(3, f32), other: @Vector(3, f32)) f32 {
    return self[0] * other[0] + self[1] * other[1] + self[2] * other[2];
}

/// Naive asf cross product function.
pub fn cross(self: @Vector(3, f32), other: @Vector(3, f32)) @Vector(3, f32) {
    return @Vector(3, f32) {
        self[1] * other[2] - self[2] * other[1],
        self[2] * other[0] - self[0] * other[2],
        self[0] * other[1] - self[1] * other[0],
    };
}

/// Scalar Multiplication doesn't exist in zig, who knew? 
/// We need it tho.
pub fn scalar(self: @Vector(3, f32) , num: f32) @Vector(3, f32) {
    return @Vector(3, f32) {
        self[0] * num,
        self[1] * num,
        self[2] * num,            
    };
} 