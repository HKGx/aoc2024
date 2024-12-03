const std = @import("std");
const ArrayList = std.ArrayList;

fn parseInt(input: []const u8, index: *usize) !i32 {
    const startIdx = index.*;

    while (index.* < input.len and std.ascii.isDigit(input[index.*])) {
        index.* += 1;
    }

    return try std.fmt.parseInt(i32, input[startIdx..index.*], 10);
}

pub fn part1(_: std.mem.Allocator, input: []const u8) !i32 {
    var sum: i32 = 0;
    var last_index: usize = 0;
    while (std.mem.indexOfPos(u8, input, last_index, "mul")) |idx| {
        last_index = idx + "mul".len;

        if (input[last_index] != '(') continue;
        last_index += 1;
        const left = try parseInt(input, &last_index);
        if (input[last_index] != ',') continue;
        last_index += 1;
        const right = try parseInt(input, &last_index);
        if (input[last_index] != ')') continue;

        sum += left * right;
    }
    return sum;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    _ = input;
    return error.Unimplemented;
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
    try std.testing.expectEqual(0, result);
}
