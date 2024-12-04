const std = @import("std");
const ArrayList = std.ArrayList;

fn parseInt(input: []const u8, index: *usize) !i32 {
    const startIdx = index.*;

    while (index.* < input.len and std.ascii.isDigit(input[index.*])) {
        index.* += 1;
    }

    return try std.fmt.parseInt(i32, input[startIdx..index.*], 10);
}

fn parseMul(input: []const u8, index: *usize, do: bool) !i32 {
    index.* += "mul".len;
    if (!do) return error.NotDo;

    if (input[index.*] != '(') return error.UnexpectedChar;
    index.* += 1;
    const left = try parseInt(input, index);
    if (input[index.*] != ',') return error.UnexpectedChar;
    index.* += 1;
    const right = try parseInt(input, index);
    if (input[index.*] != ')') return error.UnexpectedChar;

    return left * right;
}

pub fn part1(_: std.mem.Allocator, input: []const u8) !i32 {
    var sum: i32 = 0;
    var last_index: usize = 0;
    while (std.mem.indexOfPos(u8, input, last_index, "mul")) |idx| {
        last_index = idx;
        const result = parseMul(input, &last_index, true) catch continue;
        sum += result;
    }
    return sum;
}

const Find = union(enum) {
    do: usize,
    dont: usize,
    mul: usize,
};

fn findNearest(input: []const u8, index: usize) ?Find {
    const max = std.math.maxInt(usize);
    const dont = std.mem.indexOfPos(u8, input, index, "don't") orelse max;
    const do = std.mem.indexOfPos(u8, input, index, "do") orelse max;
    const mul = std.mem.indexOfPos(u8, input, index, "mul") orelse max;

    const min = @min(mul, @min(dont, do));
    if (min == max) return null;

    if (min == dont) return Find{ .dont = dont };
    if (min == do) return Find{ .do = do };
    return Find{ .mul = mul };
}

pub fn part2(_: std.mem.Allocator, input: []const u8) !i32 {
    var sum: i32 = 0;
    var last_index: usize = 0;
    var do = true;

    while (findNearest(input, last_index)) |find| {
        switch (find) {
            .dont => |idx| {
                last_index = idx + "dont".len;
                do = false;
            },
            .do => |idx| {
                last_index = idx + "do".len;
                do = true;
            },
            .mul => |idx| {
                last_index = idx;
                const result = parseMul(input, &last_index, do) catch continue;
                sum += result;
            },
        }
    }

    return sum;
}

pub fn main() !void {
    const data = @embedFile("data/day03.input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.testing.expect(gpa.deinit() == .ok) catch std.debug.panic("failed to deinitialize allocator", .{});

    {
        const start = std.time.nanoTimestamp();
        const part1_result = try part1(allocator, data);
        const end = std.time.nanoTimestamp();
        const elapsed = end - start;
        std.debug.print("Part 1 ({} ns): {}\n", .{ elapsed, part1_result });
    }

    {
        const start = std.time.nanoTimestamp();
        const part2_result = try part2(allocator, data);
        const end = std.time.nanoTimestamp();
        const elapsed = end - start;
        std.debug.print("Part 2 ({} ns): {}\n", .{ elapsed, part2_result });
    }
}

test part1 {
    const example = @embedFile("./data/day03.part1.example.txt");
    const result = try part1(std.testing.allocator, example);
    try std.testing.expectEqual(161, result);
}

test part2 {
    const example = @embedFile("./data/day03.part2.example.txt");
    const result = try part2(std.testing.allocator, example);
    try std.testing.expectEqual(48, result);
}
