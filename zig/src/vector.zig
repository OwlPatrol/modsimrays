const std = @import("std");
const RndGen = std.rand.RndGen;

fn floatRand() f32 {
    var rand = RndGen.init(0);
    var x = rand.random().float(f32);
    return if (rand.random().boolean()) x else - x; 
}

/// A struct to deal with 3-dimensional vectors and colors
pub const Vec3 = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    
    /// Constructor for a Vec3
    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3 {
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn random() Vec3 {
        return Vec3 {
            .x = floatRand(),
            .y = floatRand(),
            .z = floatRand(),
        };
    }

    pub fn norm (self: Vec3) f32 {
        return @sqrt(self.dot(self));
    }

    pub fn normalize (self: Vec3) Vec3 {
        norm = self.norm;
        return  if(norm == 0) 0 else self.scalar(1 / norm);
    }

    /// Implementation of dot product handling
    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    /// Naive asf cross product function.
    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    /// Scalar Multiplication doesn't exist in zig, who knew? 
    /// We need it tho.
    pub fn scalar(self: Vec3, num: f32) Vec3 {
        return Vec3 {
            .x = self.x * num,
            .y = self.y * num,
            .z = self.z * num,            
        };
    } 
};