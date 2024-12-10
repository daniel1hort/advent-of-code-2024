const std = @import("std");
const all = @import("imports.zig");

pub fn main() !void {
    try all.day01.part1();
    try all.day01.part2();

    try all.day02.part1();
    try all.day02.part2();

    try all.day03.part1();
    try all.day03.part2();

    try all.day04.part1();
    try all.day04.part2();
}
