const std = @import("std");
const ArrayList = std.ArrayList;
const example = @embedFile("data/day01.example.txt");

const List = struct { first: ArrayList(i32), second: ArrayList(i32) };

fn parseNumbers(allocator: std.mem.Allocator, input: []const u8) !List {
    var numbers = List{ .first = ArrayList(i32).init(allocator), .second = ArrayList(i32).init(allocator) };

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        const first = words.next().?;
        const second = words.next().?;
        const firstInt = std.fmt.parseInt(i32, first, 10) catch unreachable;
        const secondInt = std.fmt.parseInt(i32, second, 10) catch unreachable;
        try numbers.first.append(firstInt);
        try numbers.second.append(secondInt);
    }
    return numbers;
}

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const numbers = try parseNumbers(allocator, input);
    defer numbers.first.deinit();
    defer numbers.second.deinit();
    std.mem.sort(i32, numbers.first.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, numbers.second.items, {}, comptime std.sort.asc(i32));

    var total: u32 = 0;
    for (numbers.first.items, numbers.second.items) |left, right| {
        total += @abs(left - right);
    }
    return @intCast(total);
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const numbers = try parseNumbers(allocator, input);
    defer numbers.first.deinit();
    defer numbers.second.deinit();

    var total: usize = 0;
    for (numbers.first.items) |left| {
        const multiplier = std.mem.count(i32, numbers.second.items, &.{left});
        const l = @as(usize, @intCast(left));
        total += l * multiplier;
    }
    return @intCast(total);
}

pub fn part2_new(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const numbers = try parseNumbers(allocator, input);
    defer numbers.first.deinit();
    defer numbers.second.deinit();

    var total: i32 = 0;
    var counts = std.AutoHashMap(i32, i32).init(allocator);
    defer counts.deinit();

    for (numbers.second.items) |value| {
        const count = counts.get(value) orelse 0;
        try counts.put(value, count + 1);
    }

    for (numbers.first.items) |value| {
        const count = counts.get(value) orelse 0;
        total += value * count;
    }

    return total;
}

pub fn main() !void {
    const data = @embedFile("data/day1.input.txt");
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

    {
        const start = std.time.nanoTimestamp();
        const part2_new_result = try part2_new(allocator, data);
        const end = std.time.nanoTimestamp();
        const elapsed = end - start;
        std.debug.print("Part 2 (new) ({} ns): {}\n", .{ elapsed, part2_new_result });
    }
}

test part1 {
    const result = try part1(std.testing.allocator, example);
    try std.testing.expectEqual(11, result);
}

test part2 {
    const result = try part2(std.testing.allocator, example);
    try std.testing.expectEqual(31, result);
}

test part2_new {
    const result = try part2_new(std.testing.allocator, example);
    try std.testing.expectEqual(31, result);
}
