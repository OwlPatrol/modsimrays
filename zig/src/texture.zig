const Color = @import("color.zig");
const Vec3 = @import("Vec3.zig");
const ColorValue = @Vector(3, f64);
const Point = @Vector(3, f64);


pub const Texture = union(enum) {
    
    .solidColor: SolidColor,

    pub fn colorValue(self: Texture, u: f64, v:f64, p: *Point) ColorValue {
        switch(self) {
            .solidColor => return .solidColor.colorValue;
        }
    }
}

pub const SolidColor = struct {
    color_value: ColorValue,

    pub fn solidColor(r: f64, g: f64, b: f64) SolidColor {
        return SolidColor {.color_value = ColorValue {r, g, b}};
    }

    pub fn colorValue(self: SolidColor, u:f64, v: f64, p: *Point) ColorValue {
        return self.color_value;
    }

}