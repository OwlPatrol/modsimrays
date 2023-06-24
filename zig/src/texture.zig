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
    color_value

}