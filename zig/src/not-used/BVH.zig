const HittableList = @import("hitlist.zig").HittableList;
const BoundingBox = @import("boundingBox.zig").BoundingBox;
const Ray = @import("ray.zig").Ray;
//const Shape = @import("shapes.zig")-Shape;
const HitRecord = @import("hitRecord.zig").HitRecord;

pub const BvhNode = struct {

    //left: *Shape,
    //right: *Shape,
    box: BoundingBox,
    

    pub fn init(list: *HittableList, timeStart: f64, timeEnd:f64) BvhNode {
        _ = list;
        _ = timeStart + timeEnd;
    }

    pub fn hit(self: BvhNode, ray: Ray, t_min: f64, t_max: f64, rec: *HitRecord) bool {
        if(!self.box.hit(ray, t_min, t_max)) return false;
        const hit_left = self.left.*.hit(ray, t_min, t_max, rec);
        const hit_right = self.right.*.hit(ray, t_min, if(hit_left) rec.t orelse t_max, rec);
        
        return (hit_left || hit_right);
    }

    pub fn boundingBox(self: BvhNode, output: *BoundingBox) bool {
        output.*.min = self.box.min;
        output.*.min = self.box.min;
        return true;
    }
};