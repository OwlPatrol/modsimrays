const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Color = @import("writeColor.zig");
const HittableList = @import("hitlist.zig").HittableList;
const Shape = @import("shapes.zig").Shape;
const Material = @import("materials.zig").Material;
const Texture = @import("texture.zig").Texture;
const Point = @Vector(3, f64);
const RndGen = std.rand.DefaultPrng;
const time = std.time;
const point = Vec3.init;

var rand = RndGen.init(0);

pub fn floatRand(min: f64, max: f64) f64 {
    return min + (max - min) * rand.random().float(f64);
}

pub fn u32Rand(max: u32) u32 {
    return rand.random().uintAtMost(u32, max);
}

pub fn clamp(x: f64, min: f64, max: f64) f64 {
    if (x < min) return min;
    if (x > max) return max;
    return x;
}

pub fn tinyScene(scene: *HittableList) !void {
    for(0..10) |_| {
        const center = point(@as(f64, @floatFromInt(u32Rand(11))) + 0.9 * floatRand(0, 1), 0.2, @as(f64, @floatFromInt(u32Rand(11))) + 0.9 * floatRand(0, 1),
            );
        const albedo = Vec3.random(0.5, 1) * Vec3.random(0.5, 1);
        var fuzz = floatRand(0, 0.5);
        const sphere_material = Material.makeMetal(albedo, fuzz);
        try scene.addShape(Shape.stationarySphere(center, 0.2, sphere_material));
    }
}

pub fn twoPerlinSpheres(scene: *HittableList) !void {
    var pertext = try Texture.noiseTexture(4);
    const material_ground = try Material.texturedLambertian(pertext);
    try scene.addShape(try Shape.stationarySphere(.{ 0, -1000.0, 0 }, 1000.0, material_ground));
    try scene.addShape(try Shape.stationarySphere(.{ 0, 2.0, 0 }, 2.0, material_ground));  
}

pub fn twoSpheres(scene: *HittableList) !void {
    const checker = try Texture.checkerInit(try Texture.solidColor(0.2, 0.3, 0.1), try Texture.solidColor(0.9, 0.9, 0.9)); 
    const material_ground = try Material.texturedLambertian(checker);
    try scene.addShape(try Shape.stationarySphere(.{ 0, -10.0, 0 }, 10.0, material_ground));
    try scene.addShape(try Shape.stationarySphere(.{ 0, 10.0, 0 }, 10.0, material_ground));  
}

pub fn earth(scene: *HittableList) !void {
    const earth_texture = try Texture.imageInit("img/earthmap.png");
    const material_ground = try Material.texturedLambertian(earth_texture);
    try scene.addShape(try Shape.stationarySphere(.{ 0, 0, 0 }, 2, material_ground));
}

pub fn randomScene(scene: *HittableList) !void {

    // Add floor
    //const checker = try Texture.checkerInit(try Texture.solidColor(0.2, 0.3, 0.1), try Texture.solidColor(0.9, 0.9, 0.9));
    //const material_ground = try Material.texturedLambertian(checker);
    var pertext = try Texture.noiseTexture(4);
    const material_ground = try Material.texturedLambertian(pertext);
    try scene.addShape(try Shape.stationarySphere(.{ 0, -1000.0, 0 }, 1000.0, material_ground));

    const dialectric_mat = try Material.makeDialectric(1.5);
    const lambertian_mat = try Material.makeLambertian(point(0.4, 0.2, 0.1));
    const metal_mat = try Material.makeMetal(point(0.7, 0.6, 0.5), 0.0);

    try scene.addShape(try Shape.stationarySphere(point(-4, 1, 0), 1.0, lambertian_mat));
    try scene.addShape(try Shape.stationarySphere(point(0, 1, 0), 1.0, dialectric_mat));
    try scene.addShape(try Shape.stationarySphere(point(4, 1, 0), 1.0, metal_mat));

    var a: i64 = -11;
    while (a < 11) : (a += 1) {
        var b: i64 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = floatRand(0, 1);
            const center = point(
                @as(f64, @floatFromInt(a)) + 0.9 * floatRand(0, 1),
                0.2,
                @as(f64, @floatFromInt(b)) + 0.9 * floatRand(0, 1),
            );
            if (Vec3.length(center - point(4, 0.2, 0)) > 0.9) {
                var sphere_material: *Material = undefined;

                if (choose_mat < 0.8) {
                    // Diffuse
                    const albedo = Vec3.random(0, 1) * Vec3.random(0, 1);
                    sphere_material = try Material.makeLambertian(albedo);
                    //const centerEnd = center + Vec3.init(0, floatRand(0, 0.5), 0);
                    //try scene.addShape(try Shape.movingSphere(center, centerEnd, 0.0, 1.0, 0.2, sphere_material));
                    try scene.addShape(try Shape.stationarySphere(center, 0.2, sphere_material));
                } else if (choose_mat < 0.95) {
                    // Metal
                    const albedo = Vec3.random(0.5, 1) * Vec3.random(0.5, 1);
                    var fuzz = floatRand(0, 0.5);
                    sphere_material = try Material.makeMetal(albedo, fuzz);
                    try scene.addShape(try Shape.stationarySphere(center, 0.2, sphere_material));
                } else {
                    // glass
                    sphere_material = try Material.makeDialectric(1.5);
                    try scene.addShape(try Shape.stationarySphere(center, 0.2, sphere_material));
                }
            }
        }
    }
}