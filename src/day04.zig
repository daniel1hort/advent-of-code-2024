//! --- Day 4: Ceres Search ---
//! "Looks like the Chief's not here. Next!" One of The Historians pulls out a device and pushes the only button on it. After a brief flash, you recognize the interior of the Ceres monitoring station!
//!
//! As the search for the Chief continues, a small Elf who lives on the station tugs on your shirt; she'd like to know if you could help her with her word search (your puzzle input). She only has to find one word: XMAS.
//!
//! This word search allows words to be horizontal, vertical, diagonal, written backwards, or even overlapping other words. It's a little unusual, though, as you don't merely need to find one instance of XMAS - you need to find all of them. Here are a few ways XMAS might appear, where irrelevant characters have been replaced with .:
//!
//! ..X...
//! .SAMX.
//! .A..A.
//! XMAS.S
//! .X....
//! The actual word search will be full of letters instead. For example:
//!
//! MMMSXXMASM
//! MSAMXMSMSA
//! AMXSXMAAMM
//! MSAMASMSMX
//! XMASAMXAMM
//! XXAMMXXAMA
//! SMSMSASXSS
//! SAXAMASAAA
//! MAMMMXMMMM
//! MXMXAXMASX
//! In this word search, XMAS occurs a total of 18 times; here's the same word search again, but where letters not involved in any XMAS have been replaced with .:
//!
//! ....XXMAS.
//! .SAMXMS...
//! ...S..A...
//! ..A.A.MS.X
//! XMASAMX.MM
//! X.....XA.A
//! S.S.S.S.SS
//! .A.A.A.A.A
//! ..M.M.M.MM
//! .X.X.XMASX
//! Take a look at the little Elf's word search. How many times does XMAS appear?
//!
//! --- Part Two ---
//! The Elf looks quizzically at you. Did you misunderstand the assignment?
//!
//! Looking for the instructions, you flip over the word search to find that this isn't actually an XMAS puzzle; it's an X-MAS puzzle in which you're supposed to find two MAS in the shape of an X. One way to achieve that is like this:
//!
//! M.S
//! .A.
//! M.S
//! Irrelevant characters have again been replaced with . in the above diagram. Within the X, each MAS can be written forwards or backwards.
//!
//! Here's the same example from before, but this time all of the X-MASes have been kept instead:
//!
//! .M.S......
//! ..A..MSMS.
//! .M.S.MAA..
//! ..A.ASMSM.
//! .M.S.M....
//! ..........
//! S.S.S.S.S.
//! .A.A.A.A..
//! M.M.M.M.M.
//! ..........
//! In this example, an X-MAS appears 9 times.
//!
//! Flip the word search from the instructions back over to the word search side and try again. How many times does an X-MAS appear?

const std = @import("std");

pub fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = try readInput(allocator);
    defer allocator.free(file_contents);
    const n = std.mem.count(u8, file_contents, "\r\n");
    const _m = std.mem.indexOf(u8, file_contents, "\r").?;
    const line_len = _m + 2;

    const matrix = try allocator.alloc([]u8, n);
    for (0..n) |index| {
        const start = index * line_len;
        const end = start + _m;
        matrix[index] = file_contents[start..end];
    }

    var count: u32 = 0;
    for (0..n) |row| {
        for (0.._m - 3) |col| {
            const x = matrix[row][col + 0];
            const m = matrix[row][col + 1];
            const a = matrix[row][col + 2];
            const s = matrix[row][col + 3];

            if (xmas(x, m, a, s))
                count += 1;
        }
    }

    for (0.._m) |col| {
        for (0..n - 3) |row| {
            const x = matrix[row + 0][col];
            const m = matrix[row + 1][col];
            const a = matrix[row + 2][col];
            const s = matrix[row + 3][col];
            if (xmas(x, m, a, s))
                count += 1;
        }
    }

    for (3..n) |row| {
        for (0.._m - 3) |col| {
            const x = matrix[row - 0][col + 0];
            const m = matrix[row - 1][col + 1];
            const a = matrix[row - 2][col + 2];
            const s = matrix[row - 3][col + 3];

            if (xmas(x, m, a, s))
                count += 1;
        }
    }

    for (0..n - 3) |row| {
        for (0.._m - 3) |col| {
            const x = matrix[row + 0][col + 0];
            const m = matrix[row + 1][col + 1];
            const a = matrix[row + 2][col + 2];
            const s = matrix[row + 3][col + 3];

            if (xmas(x, m, a, s))
                count += 1;
        }
    }

    std.debug.print("day04 part1 answer = {d}\n", .{count});
}

pub fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = try readInput(allocator);
    defer allocator.free(file_contents);
    const n = std.mem.count(u8, file_contents, "\r\n");
    const _m = std.mem.indexOf(u8, file_contents, "\r").?;
    const line_len = _m + 2;

    const matrix = try allocator.alloc([]u8, n);
    for (0..n) |index| {
        const start = index * line_len;
        const end = start + _m;
        matrix[index] = file_contents[start..end];
    }

    var count: u32 = 0;
    for (0..n - 2) |row| {
        for (0.._m - 2) |col| {
            const a = matrix[row + 0][col + 0];
            const b = matrix[row + 0][col + 2];
            const c = matrix[row + 2][col + 2];
            const d = matrix[row + 2][col + 0];
            const e = matrix[row + 1][col + 1];
            if (x_mas(a, b, c, d, e))
                count += 1;
        }
    }

    std.debug.print("day04 part2 answer = {d}\n", .{count});
}

fn readInput(allocator: std.mem.Allocator) ![]u8 {
    var file = try std.fs.cwd().openFile("input/day04.in", .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    return file_contents;
}

fn xmas(x: u8, m: u8, a: u8, s: u8) bool {
    const sequence = x == 'X' and m == 'M' and a == 'A' and s == 'S';
    const reverse = x == 'S' and m == 'A' and a == 'M' and s == 'X';
    return sequence or reverse;
}

// M.S | M.M | S.M | S.S
// .A. | .A. | .A. | .A.
// M.S | S.S | S.M | M.M
fn x_mas(a: u8, b: u8, c: u8, d: u8, e: u8) bool {
    const o1 = a == 'M' and b == 'S' and c == 'S' and d == 'M';
    const o2 = a == 'M' and b == 'M' and c == 'S' and d == 'S';
    const o3 = a == 'S' and b == 'M' and c == 'M' and d == 'S';
    const o4 = a == 'S' and b == 'S' and c == 'M' and d == 'M';
    return (o1 or o2 or o3 or o4) and e == 'A';
}
