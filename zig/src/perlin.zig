const std = @import("std");
const utils = @import("utils.zig");
const Vec3 = @import("Vec3.zig");
const floatRand = utils.floatRand;
const u32Rand = utils.u32Rand;
const Point = @Vector(3, f64);
const Self = @This();



const point_count: u9 = 256;
ranvec: [point_count]Point,
perm_x: [point_count]usize,
perm_y: [point_count]usize,
perm_z: [point_count]usize,

pub fn perlin() Self {
    var ranvec: [point_count]Point = undefined;
    for(0..point_count) |i| {
        ranvec[i] = Vec3.randomUnitVector();
    }

    var perm_x = generatePerm();
    var perm_y = generatePerm();
    var perm_z = generatePerm();
    return @This() {.ranvec = ranvec, .perm_x = perm_x, .perm_y = perm_y, .perm_z = perm_z};
}

pub fn turb(self: Self, p: Point) f64 {
    const depth = 7;
    var accum: f64 = 0.0;
    var temp_p = p;
    var weight: f64 = 1.0;
    for(0..depth) |_| {
        accum += weight*self.noise(temp_p);
        weight *= 0.5;
        temp_p = Vec3.scalar(temp_p, 2);
    }
    return @fabs(accum);
}

pub fn noise(self: Self, point: Point) f64 {
    var u = point[0] - @floor(point[0]);
    var v = point[1] - @floor(point[1]);
    var w = point[2] - @floor(point[2]);

    var i: i32 = @intFromFloat(@floor(point[0]));
    var j: i32 = @intFromFloat(@floor(point[1]));
    var k: i32 = @intFromFloat(@floor(point[2]));

    var c: [2][2][2]Point = undefined;

    for(0..2) |di| {
        for(0..2) |dj| {
            for(0..2) |dk| {
                c[di][dj][dk] = self.ranvec[
                    self.perm_x[@intCast(i + @as(i32,@intCast(di)) & 255)] ^ 
                    self.perm_y[@intCast(j + @as(i32,@intCast(dj)) & 255)] ^ 
                    self.perm_z[@intCast(k + @as(i32,@intCast(dk)) & 255)]
                ];
            }
        }
    }
    return trilinearInterpolation(c, u, v, w);
}

fn trilinearInterpolation(c: [2][2][2]Point, u: f64, v: f64, w: f64) f64 {
    const uu = u*u*(3-2*u);
    const vv = v*v*(3-2*v);
    const ww = w*w*(3-2*w);

    var accum: f64 = 0.0;
    for(0..2) |i| {
        for(0..2) |j| {
            for(0..2) |k| {
                const _i:f64 = @floatFromInt(i);
                const _j:f64 = @floatFromInt(j);
                const _k:f64 = @floatFromInt(k);

                const weight_v = Point {u-_i, v-_j, w-_k};

                 accum += 
                    (_i*uu + (1-_i)*(1-uu)) *
                    (_j*vv + (1-_j)*(1-vv)) *
                    (_k*ww + (1-_k)*(1-ww)) *
                    Vec3.dot(c[i][j][k], weight_v);
            }
        }
    }
    return accum;
}

fn generatePerm() [point_count]usize {
    var p: [point_count]usize = undefined;
    for (0..point_count) |i| {
        p[i] = i;
    }
    permute(&p, point_count);
    return p;
}

fn permute(p: []usize, n: usize) void {
   var i = n - 1;
    while(i > 0) : (i -= 1) {   
        var target = u32Rand(@intCast(i));
        var temp = p[i];
        p[i] = p[target];
        p[target] = temp;
    }
}