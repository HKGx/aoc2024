const std = @import("std");
const util = @import("util.zig");
const Vec2 = util.Vec2;
const ArrayList = std.ArrayList;

const example = @embedFile("data/day04.example.txt");

pub fn parseLines(allocator: std.mem.Allocator, input: []const u8) ![][]const u8 {
    const lines_count = std.mem.count(u8, input, "\n");
    const lines = try allocator.alloc([]const u8, lines_count + 1);
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;
    while (iter.next()) |line| : (i += 1) {
        std.debug.print("`{s}`\n", .{line});
        const newLine = try allocator.alloc(u8, line.len);
        @memcpy(newLine, line);
        lines[i] = newLine;
    }

    return lines;
}

const FloodSearchState = enum {
    empty,
    x,
    xm,
    xma,

    pub fn nextState(self: FloodSearchState) ?FloodSearchState {
        return switch (self) {
            .empty => .x,
            .x => .xm,
            .xm => .xma,
            else => null,
        };
    }

    pub fn searchSymbol(self: FloodSearchState) u8 {
        return switch (self) {
            .empty => 'X',
            .x => 'M',
            .xm => 'A',
            .xma => 'S',
        };
    }
};

const Vec = Vec2(i64);

const Searcher = struct {
    lines: [][]const u8,
    position: Vec,
    state: FloodSearchState = .empty,
    direction: Vec = .{ .x = 0, .y = 0 },

    inline fn get(self: Searcher, position: Vec) ?u8 {
        const x = position.x;
        const y = position.y;

        if (y >= self.lines.len or y < 0) return null;
        const line = self.lines[@intCast(y)];
        if (x >= line.len or x < 0) return null;
        return line[@intCast(x)];
    }

    pub fn searchInLine(self: Searcher) i32 {
        const directions = [_]Vec{
            Vec{ .x = -1, .y = -1 },
            Vec{ .x = 0, .y = -1 },
            Vec{ .x = 1, .y = -1 },
            Vec{ .x = -1, .y = 0 },
            Vec{ .x = 1, .y = 0 },
            Vec{ .x = -1, .y = 1 },
            Vec{ .x = 0, .y = 1 },
            Vec{ .x = 1, .y = 1 },
        };

        var total: i32 = 0;
        for (directions) |direction| {
            var searcher: Searcher = .{
                .lines = self.lines,
                .position = self.position,
                .direction = direction,
            };

            if (!searcher.searchCurrent()) continue;
            if (searcher.searchNext()) total += 1;
        }

        return total;
    }

    fn searchCurrent(self: *Searcher) bool {
        if (self.get(self.position)) |ch| {
            if (ch != self.state.searchSymbol()) return false;
            if (self.state.nextState()) |next_state| self.state = next_state;
            return true;
        }
        return false;
    }

    fn searchNext(self: *Searcher) bool {
        if (self.get(self.position.add(self.direction))) |ch| {
            if (ch != self.state.searchSymbol()) return false;
            if (self.state.nextState()) |next_state| {
                self.position.addMut(self.direction);
                self.state = next_state;
                return self.searchNext();
            }
            return true;
        }
        return false;
    }
};

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const lines = try parseLines(allocator, input);
    defer allocator.free(lines);
    defer for (lines) |line| allocator.free(line);
    var total: i32 = 0;
    for (0..lines.len) |y| {
        const line = lines[y];
        for (0..line.len) |x| {
            const searcher = Searcher{
                .lines = lines,
                .position = Vec{ .x = @intCast(x), .y = @intCast(y) },
            };
            total += searcher.searchInLine();
        }
        std.debug.print("\n", .{});
    }

    return total;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    _ = input;
    return error.Unimplemented;
}

pub fn main() !void {
    const data = @embedFile("data/day04.input.txt");
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
    try std.testing.expectEqual(18, result);
}

test part2 {
    const result = try part2(std.testing.allocator, example);
    try std.testing.expectEqual(-1, result);
}
