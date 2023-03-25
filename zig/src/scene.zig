const std = @import("std");
const Vec3 = @import("rays.zig").Vec3;

var object_list: []Shape;

const Shape = union {
    sphere: Sphere,
    cube: Cube,
};

const Sphere = struct {
    center: Vec3,
    radius: f32,

    pub fn init(center: Vec3, radius: f32) Sphere{
        .center = center;
        .radius = radius;
    }
};

const Cube = struct {
    center: Vec3,
    alignment: Vec3,
    length: f32,

    pub fn init(center: Vec3, alignmnent: Vec3, length: f32) Cube {
        .center = center;
        .alignment = alignmnent;
        .length = length;
    }
};

pub fn addObject(object:Shape) []Shape {
    object_list = []Shape {object} ++ object_list;
    return object_list;
}