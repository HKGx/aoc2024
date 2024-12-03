const std = @import("std");
const ArrayList = std.ArrayList;

const example = @embedFile("data/day02.example.txt");

const Report = ArrayList(ArrayList(i32));

fn parseLevels(allocator: std.mem.Allocator, input: []const u8) !Report {
    var report = Report.init(allocator);
    var lines = std.mem.splitScalar(u8, input, '\n');

    while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        var levels = ArrayList(i32).init(allocator);
        while (words.next()) |word| {
            const value = try std.fmt.parseInt(i32, word, 10);
            try levels.append(value);
        }
        try report.append(levels);
    }
    return report;
}

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    var arena = std.heap.ArenaAllocator.init(allocator);
    const report = try parseLevels(arena.allocator(), input);
    defer arena.deinit();

    var total_valid: i32 = 0;

    for (report.items) |levels| {
        if (isValid(levels.items)) total_valid += 1;
    }

    return total_valid;
}

fn isValid(levels: []const i32) bool {
    var asc = true;
    var desc = true;
    var previousLevel: i32 = levels[0];
    for (levels[1..]) |level| {
        const change = @abs(level - previousLevel);
        if (change < 1 or change > 3) return false;
        if (level < previousLevel) asc = false;
        if (level > previousLevel) desc = false;
        if (!asc and !desc) return false;
        previousLevel = level;
    }
    return true;
}

const RemoveOneIterator = struct {
    original: []const i32,
    new: []i32,
    index: usize = 0,

    fn next(self: *RemoveOneIterator) ?[]i32 {
        if (self.index >= self.original.len) return null;

        @memcpy(self.new[0..self.index], self.original[0..self.index]);
        @memcpy(self.new[self.index..], self.original[self.index + 1 ..]);

        self.index += 1;
        return self.new;
    }
};

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    var arena = std.heap.ArenaAllocator.init(allocator);
    const report = try parseLevels(arena.allocator(), input);
    defer arena.deinit();

    var total_valid: i32 = 0;

    for (report.items) |levels| {
        if (isValid(levels.items)) {
            total_valid += 1;
            continue;
        }

        const new = try allocator.alloc(i32, levels.items.len - 1);
        defer allocator.free(new);

        var iter = RemoveOneIterator{ .original = levels.items, .new = new };
        while (iter.next()) |removedOne| {
            if (isValid(removedOne)) {
                total_valid += 1;
                break;
            }
        }
    }

    return total_valid;
}

pub fn main() !void {
    const data = @embedFile("data/day02.input.txt");
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
    try std.testing.expectEqual(2, result);
}

test part2 {
    const result = try part2(std.testing.allocator, example);
    try std.testing.expectEqual(4, result);
}

test "part2 additional case" {
    const result = try part2(std.testing.allocator, "70 21 73 74");
    try std.testing.expectEqual(1, result);
}
