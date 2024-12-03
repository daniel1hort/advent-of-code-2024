//! --- Day 3: Mull It Over ---
//! "Our computers are having issues, so I have no idea if we have any Chief
//! Historians in stock! You're welcome to check the warehouse, though," says
//! the mildly flustered shopkeeper at the North Pole Toboggan Rental Shop. The
//! Historians head out to take a look.
//!
//! The shopkeeper turns to you. "Any chance you can see why our computers are
//! having issues again?"
//!
//! The computer appears to be trying to run a program, but its memory (your
//! puzzle input) is corrupted. All of the instructions have been jumbled up!
//!
//! It seems like the goal of the program is just to multiply some numbers. It
//! does that with instructions like mul(X,Y), where X and Y are each 1-3 digit
//! numbers. For instance, mul(44,46) multiplies 44 by 46 to get a result of
//! 2024. Similarly, mul(123,4) would multiply 123 by 4.
//!
//! However, because the program's memory has been corrupted, there are also
//! many invalid characters that should be ignored, even if they look like part
//! of a mul instruction. Sequences like mul(4*, mul(6,9!, ?(12,34), or mul
//! ( 2 , 4 ) do nothing.
//!
//! For example, consider the following section of corrupted memory:
//!
//! xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
//! Only the four highlighted sections are real mul instructions. Adding up the
//! result of each instruction produces 161 (2*4 + 5*5 + 11*8 + 8*5).
//!
//! Scan the corrupted memory for uncorrupted mul instructions. What do you get
//! if you add up all of the results of the multiplications?
//!
//! --- Part Two ---
//! As you scan through the corrupted memory, you notice that some of the
//! conditional statements are also still intact. If you handle some of the
//! uncorrupted conditional statements in the program, you might be able to get
//! an even more accurate result.
//!
//! There are two new instructions you'll need to handle:
//!
//! The do() instruction enables future mul instructions.
//! The don't() instruction disables future mul instructions.
//! Only the most recent do() or don't() instruction applies. At the beginning
//! of the program, mul instructions are enabled.
//!
//! For example:
//!
//! xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
//! This corrupted memory is similar to the example from before, but this time
//! the mul(5,5) and mul(11,8) instructions are disabled because there is a
//! don't() instruction before them. The other mul instructions function
//! normally, including the one at the end that gets re-enabled by a do()
//! instruction.
//!
//! This time, the sum of the results is 48 (2*4 + 8*5).
//!
//! Handle the new instructions; what do you get if you add up all of the
//! results of just the enabled multiplications?

const std = @import("std");

pub fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = try readInput(allocator);
    defer allocator.free(file_contents);

    var tokenizer: Tokenizer = .{
        .source = file_contents,
    };

    var count: u32 = 0;
    var num1: u32 = 0;
    var num2: u32 = 0;
    var sum: u32 = 0;
    while (tokenizer.next()) |token| {
        if (count == 0 and token == .mul) {
            count += 1;
        } else if (count == 1 and token == .open) {
            count += 1;
        } else if (count == 2 and token == .number) {
            count += 1;
            num1 = token.number;
        } else if (count == 3 and token == .comma) {
            count += 1;
        } else if (count == 4 and token == .number) {
            count += 1;
            num2 = token.number;
        } else if (count == 5 and token == .close) {
            count = 0;
            sum += num1 * num2;
        } else {
            count = 0;
        }
    }

    std.debug.print("day03 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = try readInput(allocator);
    defer allocator.free(file_contents);

    var tokenizer: Tokenizer = .{
        .source = file_contents,
    };

    var count: u32 = 0;
    var num1: u32 = 0;
    var num2: u32 = 0;
    var sum: u32 = 0;
    var enabled = true;
    var command: Token = .invalid;
    while (tokenizer.next()) |token| {
        if (token == .mul and enabled) {
            command = .mul;
            count = 1;
        } else if (command == .mul and count == 1 and token == .open) {
            count += 1;
        } else if (command == .mul and count == 2 and token == .number) {
            count += 1;
            num1 = token.number;
        } else if (command == .mul and count == 3 and token == .comma) {
            count += 1;
        } else if (command == .mul and count == 4 and token == .number) {
            count += 1;
            num2 = token.number;
        } else if (command == .mul and count == 5 and token == .close) {
            count = 0;
            sum += num1 * num2;
        } else if (token == .do) {
            command = .do;
            count = 1;
        } else if (command == .do and count == 1 and token == .open) {
            count += 1;
        } else if (command == .do and count == 2 and token == .close) {
            count = 0;
            enabled = true;
        } else if (token == .dont) {
            command = .dont;
            count = 1;
        } else if (command == .dont and count == 1 and token == .open) {
            count += 1;
        } else if (command == .dont and count == 2 and token == .close) {
            count = 0;
            enabled = false;
        } else {
            count = 0;
        }
    }

    std.debug.print("day03 part2 answer = {d}\n", .{sum});
}

fn readInput(allocator: std.mem.Allocator) ![]u8 {
    var file = try std.fs.cwd().openFile("input/day03.in", .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    return file_contents;
}

const Token = union(enum) {
    number: u32,
    mul,
    do,
    dont,
    open,
    close,
    comma,
    invalid,
};

const Tokenizer = struct {
    source: []const u8,
    pos: usize = 0,

    fn next(self: *Tokenizer) ?Token {
        if (self.pos >= self.source.len)
            return null;

        switch (self.source[self.pos]) {
            '(' => {
                self.pos += 1;
                return .open;
            },
            ')' => {
                self.pos += 1;
                return .close;
            },
            ',' => {
                self.pos += 1;
                return .comma;
            },
            '0'...'9' => {
                var end = self.pos;
                while (std.ascii.isDigit(self.source[end])) : (end += 1) {}
                const value = self.source[self.pos..end];
                const num = std.fmt.parseInt(u32, value, 10) catch 0;
                self.pos = end;
                return .{ .number = num };
            },
            'm' => {
                if (self.source.len - self.pos >= 3) {
                    const value = self.source[self.pos .. self.pos + 3];
                    if (std.mem.eql(u8, value, "mul")) {
                        self.pos += 3;
                        return .mul;
                    }
                }

                self.pos += 1;
                return .invalid;
            },
            'd' => {
                if (self.source.len - self.pos >= 5) {
                    const value2 = self.source[self.pos .. self.pos + 5];
                    if (std.mem.eql(u8, value2, "don't")) {
                        self.pos += 5;
                        return .dont;
                    }
                }

                if (self.source.len - self.pos >= 2) {
                    const value1 = self.source[self.pos .. self.pos + 2];
                    if (std.mem.eql(u8, value1, "do")) {
                        self.pos += 2;
                        return .do;
                    }
                }

                self.pos += 1;
                return .invalid;
            },
            else => {
                self.pos += 1;
                return .invalid;
            },
        }
    }
};
