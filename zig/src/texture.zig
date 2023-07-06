const std = @import("std");
const zigimg = @import("zigimg");
const WriteColor = @import("writeColor.zig");
const Vec3 = @import("Vec3.zig");
const Perlin = @import("perlin.zig");
const Color = @Vector(3, f64);
const Point = @Vector(3, f64);
const clamp = @import("utils.zig").clamp;
const page = std.heap.page_allocator;
const sin = std.math.sin;


pub const Texture = union(enum) {
    
    solid_color: *SolidColor,
    checker_texture: *CheckerTexture,
    noise_texture: *NoiseTexture,
    image_texture: *ImageTexture,

    pub fn imageInit(file_path: []const u8) !*Texture {
        var ptr = try page.create(Texture);
        ptr.* = Texture{.image_texture = try ImageTexture.init(file_path)};
        return ptr;
    }

    pub fn checkerInit(odd: *Texture, even: *Texture) !*Texture {
        var ptr = try page.create(Texture);
        ptr.* = Texture {.checker_texture = try CheckerTexture.init(odd, even)};
        return ptr;
    }

    pub fn solidColor(r: f64, g: f64, b: f64) !*Texture {
        const ptr = try page.create(Texture);
        var solid_color = try SolidColor.solidColor(r, g, b);
        ptr.* = Texture{.solid_color = solid_color};
        return ptr;
    }

    pub fn noiseTexture(scale: f64) !*Texture {
        const ptr = try page.create(Texture);
        const noise = try NoiseTexture.init(scale);
        ptr.* = Texture {.noise_texture = noise};
        return ptr;
    }

    pub fn destroy(self: Texture) void {
        switch(self.*) {
            .solid_color => |s| s.destroy(),
            .checker_texture => |c| c.destroy(),
        }
        page.destroy(self);
    }

    pub fn value(self: Texture, u: f64, v:f64, p: Point) Color {
        _ = Vec3.scalar(p, u+v);
        switch(self) {
            .solid_color => |s| return s.value(u, v, p),
            .checker_texture => |c| return c.value(u, v, p),
            .noise_texture => |n| return n.value(u, v, p),
            .image_texture => |i| return i.value(u, v, p),
        }
    }
};

const SolidColor = struct {
    color_value: Color,

    fn solidColor(r: f64, g: f64, b: f64) !*SolidColor {
        const ptr = try page.create(SolidColor);
        ptr.* = SolidColor {.color_value = Color {r, g, b}};
        return ptr;
    }

    fn destroy(self: *ImageTexture) void {
        page.destroy(self);
    }

    fn value(self: SolidColor, u:f64, v: f64, p: Point) Color {
        _ = Vec3.scalar(p, u+v);
        return self.color_value;
    }

};

const CheckerTexture = struct {
    odd: *Texture,
    even: *Texture,
    
    fn init(even: *Texture, odd: *Texture) !*CheckerTexture {
        const ptr = try page.create(CheckerTexture);
        ptr.* = CheckerTexture{.even = even, .odd = odd};
        return ptr;
    }

    fn destroy(self: *ImageTexture) void {
        page.destroy(self);
    }

    fn value(self: CheckerTexture, u: f64, v: f64, p: Point) Color {
        const sines = sin(10*p[0])*sin(10*p[1])*sin(10*p[2]);
        return if(sines < 0) self.odd.value(u, v, p) else self.even.value(u, v, p);
    }
};

const NoiseTexture = struct {
    noise: Perlin,
    scale: f64,

    fn init(scale: f64)  !*NoiseTexture {
        const ptr = try page.create(NoiseTexture);
        ptr.* = NoiseTexture{.noise = Perlin.perlin(), .scale = scale};
        return ptr;
    }

    fn destroy(self: *ImageTexture) void {
        page.destroy(self);
    }

    fn value(self: NoiseTexture, u: f64, v: f64, p: Point) Color {
        _ = u-v;
        return Vec3.scalar(Color{1,1,1}, 0.5*(1.0+sin(self.scale*p[2] + 10*self.noise.turb(p))));
    }
};

const ImageTexture = struct {
    const bytes_per_pixel: usize = 4;
    data: []const u8,
    width: usize, 
    height: usize,
    bytes_per_scanline: usize,

    fn init(file_path: []const u8) !*ImageTexture {
        var img = try zigimg.Image.fromFilePath(page, file_path);
        defer img.deinit();
        const ptr = try page.create(ImageTexture);
        var data = try page.dupe(u8, img.rawBytes());
        ptr.* = ImageTexture {.data = data, .width = img.width, .height = img.height, .bytes_per_scanline = bytes_per_pixel*img.height};
        return ptr;
    }

    fn destroy(self: *ImageTexture) void {
        page.destroy(self);
    }

    fn value(self: ImageTexture, u: f64, v: f64, p: Point) Color {
        _ = p;
        var _u = clamp(u, 0.0, 1.0);
        var _v = 1.0 - clamp(v, 0.0, 1.0);
        var w: f64 = @floatFromInt(self.width);
        var h: f64 = @floatFromInt(self.height);
        var i: usize = @intFromFloat(_u*w);
        var j: usize = @intFromFloat(_v*h);

        if(i >= self.width) i = self.width-1;
        if(j >= self.height) j = self.height-1;

        const color_scale = 1.0/255.0;
        const index =j*self.bytes_per_scanline+i*bytes_per_pixel;
        var color = Color{@floatFromInt(self.data[index]), @floatFromInt(self.data[index+1]), @floatFromInt(self.data[index+2])};
        color = Vec3.scalar(color, color_scale);
        return color;
    }
};