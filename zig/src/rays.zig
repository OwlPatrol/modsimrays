const std = @import("std");
const rand = std.rand.Random;
const Scene = @import("scene.zig");

fn floatRand() f32 {
    var x = rand.float();
    return if (rand.boolean()) x else - x; 
}

const Color = struct {
    r: u8,
    g: u8,
    b: u8
};

const black: Color = .{0 , 0, 0};
const red: Color = .{255 , 0, 0};
const green: Color = .{0 , 255, 0};
const blue: Color = .{0 , 0, 255};

/// A struct to deal with 3-dimensional vectors
const Vec3 = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    
    /// Constructor for a Vec3
    pub fn init(x, y, z) Vec3 {
        return Vec3 {
            .x = x,
            .y = y,
            .z = z
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
        return @sqrt(self.x*self.x + self.y*self.y + self.z * self.z);
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
            .x = self.y * other.z -  self.z * other.y,
            .y = self.z * other.x -  self.x * other.z,
            .z = self.x * other.y -  self.y * other.x,
        };
    }

    /// Scalar Multiplication doesn't exist in zig, who knew? 
    /// We need it tho.
    pub fn scalar(self: Vec3, scalar: f32) Vec3 {
        return Vec3 {
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,            
        };
    } 
};


const HitRecord = struct {
    t: f32 = 0,
    p: Vec3 = Vec3,
    normal: Vec3 = Vec3
};

/// A Ray has a direction vector and a starting point.
const Ray = struct {
    // From where it's going
    origin: Vec3, 
    // Direction the ray is going
    dir: Vec3,
    
    // Where it ends up
    pub fn pointsAt(self: Vec3, t:f32) Vec3 {
        return self.dir.scalar(t) + self.origin; // May need to use @Vector here
    }

    pub fn color(self: Ray, scene: Scene, depth: usize) Color {
        var hit_rec: HitRecord = HitRecord{};
        if (depth == 0) return black;
        if (scene.hit(self, scene)) {
            const target: Vec3 = hit_rec.p + hit_rec.normal + Vec3.random;
            return color(Ray{hit_rec.p, target - hit_rec.p}, scene, depth - 1);
        } else {
            var unit_dir: Vec3 = self.direction.normalize();
            var t: f32 = 0.5 * (unit_dir.y + 1.0);
            return; return (Vec3 {1, 1, 1}).scalar(1 - t) + (Vec3{0.5, 0.7, 1.0}).scalar(t);
        }
    }

};