const std = @import("std");
const ArrayList = std.ArrayList;

const example = @embedFile("data/day$$.example.txt");

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    _ = input;
    return error.Unimplemented;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    _ = input;
    return error.Unimplemented;
}

pub fn main() !void {
    const data = @embedFile("data/day$$.input.txt");
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
    const result = try part1(std.testing.allocator, example);
    try std.testing.expectEqual(0, result);
}

test part2 {
    const result = try part2(std.testing.allocator, example);
    try std.testing.expectEqual(0, result);
}
