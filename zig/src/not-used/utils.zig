const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const time = std.time;

pub fn floatRand(min: f64, max: f64) f64 {
    var rand = RndGen.init(0);
    rand.seed(@intCast(u64, time.nanoTimestamp()));
    return min + (max - min) * rand.random().float(f64);
}