const std = @import("std");
const WriteColor = @import("writeColor.zig");
const Vec3 = @import("Vec3.zig");
const Perlin = @import("perlin.zig");
const Color = @Vector(3, f64);
const Point = @Vector(3, f64);
const page = std.heap.page_allocator;
const sin = std.math.sin;


pub const Texture = union(enum) {
    
    solid_color: *SolidColor,
    checker_texture: *CheckerTexture,
    noise_texture: *NoiseTexture,

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

    pub fn noiseTexture() !*Texture {
        const ptr = try page.create(Texture);
        const noise = try NoiseTexture.init();
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

    fn value(self: CheckerTexture, u: f64, v: f64, p: Point) Color {
        const sines = sin(10*p[0])*sin(10*p[1])*sin(10*p[2]);
        return if(sines < 0) self.odd.value(u, v, p) else self.even.value(u, v, p);
    }
};

const NoiseTexture = struct {
    noise: Perlin,

    fn init()  !*NoiseTexture {
        const ptr = try page.create(NoiseTexture);
        ptr.* = NoiseTexture{.noise = Perlin.perlin()};
        return ptr;
    }

    fn value(self: NoiseTexture, u: f64, v: f64, p: Point) Color {
        _ = u-v;
        return Vec3.scalar(Color{1,1,1}, self.noise.noise(p));
    }
};