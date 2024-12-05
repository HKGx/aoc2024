const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;

const example = @embedFile("data/day05.example.txt");

const Program = struct {
    rules: ArrayList(util.Vec2(i32)),
    updates: ArrayList(ArrayList(i32)),

    pub fn deinit(self: Program) void {
        self.rules.deinit();
        for (self.updates.items) |update| {
            update.deinit();
        }
        self.updates.deinit();
    }
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !Program {
    var rules = ArrayList(util.Vec2(i32)).init(allocator);
    var updates = ArrayList(ArrayList(i32)).init(allocator);
    var iter = std.mem.splitSequence(u8, input, "\n\n");
    const rawRules = iter.next().?;
    const rawUpdates = iter.next().?;

    var rulesLines = std.mem.splitScalar(u8, rawRules, '\n');
    while (rulesLines.next()) |line| {
        var ruleIter = std.mem.splitScalar(u8, line, '|');
        const left = try std.fmt.parseInt(i32, ruleIter.next().?, 10);
        const right = try std.fmt.parseInt(i32, ruleIter.next().?, 10);
        try rules.append(.{ .x = left, .y = right });
    }

    var updatesLines = std.mem.splitScalar(u8, rawUpdates, '\n');
    while (updatesLines.next()) |line| {
        var update = ArrayList(i32).init(allocator);
        var updateIter = std.mem.splitScalar(u8, line, ',');
        while (updateIter.next()) |rawValue| {
            const value = try std.fmt.parseInt(i32, rawValue, 10);
            try update.append(value);
        }
        try updates.append(update);
    }

    return .{ .rules = rules, .updates = updates };
}

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const program = try parseInput(allocator, input);
    defer program.deinit();

    return error.Unimplemented;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    _ = input;
    return error.Unimplemented;
}

pub fn main() !void {
    const data = @embedFile("data/day05.input.txt");
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
    try std.testing.expectEqual(143, result);
}

test part2 {
    const result = try part2(std.testing.allocator, example);
    try std.testing.expectEqual(0, result);
}
