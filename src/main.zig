const std = @import("std");
const all = @import("imports.zig");

pub fn main() !void {
    try all.day01.part1();
    try all.day01.part2();
}
