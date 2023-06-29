const std = @import("std");
const utils = @import("utils.zig");
const floatRand = utils.floatRand;
const u32Rand = utils.u32Rand;
const Point = @Vector(3, f64);
const Self = @This();


const point_count: u9 = 256;
ran_float: [point_count]f64,
perm_x: [point_count]usize,
perm_y: [point_count]usize,
perm_z: [point_count]usize,

pub fn perlin() Self {
    var arr:[point_count]f64 = undefined;
    for(0..point_count) |i| {
        arr[i] = floatRand(0, 1);
    }

    var perm_x = generatePerm();
    var perm_y = generatePerm();
    var perm_z = generatePerm();
    return @This() {.ran_float = arr, .perm_x = perm_x, .perm_y = perm_y, .perm_z = perm_z};
}

pub fn _noise(self: Self, point: Point) f64 {
    const i = @floatToInt(i32, 4*point[0]) & 255;
    const j = @floatToInt(i32, 4*point[1]) & 255;
    const k = @floatToInt(i32, 4*point[2]) & 255;

    return self.ran_float[self.perm_x[@intCast(usize,i)]^self.perm_y[@intCast(usize,j)]^self.perm_z[@intCast(usize,k)]];
}

pub fn noise(self: Self, point: Point) f64 {
    var u = point[0] - @floor(point[0]);
    var v = point[1] - @floor(point[1]);
    var w = point[2] - @floor(point[2]);
    u = u*u*(3-2*u);
    v = v*v*(3-2*v);
    w = w*w*(3-2*w);


    var i = @floatToInt(i32, @floor(point[0]));
    var j = @floatToInt(i32, @floor(point[1]));
    var k =  @floatToInt(i32, @floor(point[2]));

    var c: [2][2][2]f64 = undefined;

    for(0..2) |di| {
        for(0..2) |dj| {
            for(0..2) |dk| {
                const _di = @intCast(i32, di);
                const _dj = @intCast(i32, dj);
                const _dk = @intCast(i32, dk);
                c[di][dj][dk] = self.ran_float[
                    self.perm_x[@intCast(usize, i + _di & 255)] ^ 
                    self.perm_y[@intCast(usize, j + _dj & 255)] ^ 
                    self.perm_z[@intCast(usize, k + _dk & 255)]
                ];
            }
        }
    }
    return trilinearInterpolation(c, u, v, w);
}

fn trilinearInterpolation(c: [2][2][2]f64, u: f64, v: f64, w: f64) f64 {
    var accum: f64 = 0.0;
    for(0..2) |i| {
        for(0..2) |j| {
            for(0..2) |k| {
                const _i = @intToFloat(f64, i);
                const _j = @intToFloat(f64, j);
                const _k = @intToFloat(f64, k);
                accum +=
                    (_i*u + (1-_i)*(1-u)) *
                    (_j*v + (1-_j)*(1-v)) *
                    (_k*w + (1-_k)*(1-w)) *
                    c[i][j][k];
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
        var target = u32Rand(@intCast(u32,i));
        var temp = p[i];
        p[i] = p[target];
        p[target] = temp;
    }
}