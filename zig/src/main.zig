const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("Memory leak occured!\n");
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    // Skip first arg as it's the executable file
    _ = args.next();
    const command = args.next() orelse std.debug.panic("Option for command was not provided", .{});
    const raw_day = args.next() orelse std.debug.panic("Option for day was not provided", .{});

    const day = std.fmt.parseInt(u8, raw_day, 10) catch std.debug.panic("Couldn't parse '{s}' as u8", .{raw_day});

    if (std.mem.eql(u8, command, "generate")) return generate(allocator, day);

    std.debug.panic("Unkown command '{s}'!", .{command});
}

pub fn generate(_: std.mem.Allocator, day: u8) !void {
    const template = @embedFile("./solutions/day$$.zig");
    const template_array_type = @typeInfo(@TypeOf(template)).Pointer.child;
    var file_content_buffer: [@sizeOf(template_array_type) - 1]u8 = undefined;

    const num = std.fmt.digits2(day);
    const replacements = std.mem.replace(u8, template, "$$", &num, &file_content_buffer);
    if (replacements != 2) std.debug.panic("Invalid number of replacements: {d}", .{replacements});

    const cwd = std.fs.cwd();
    const solutions_dir = try cwd.openDir("./src/solutions", .{});

    var file_name_buffer: [9]u8 = undefined;
    _ = try std.fmt.bufPrint(&file_name_buffer, "day{s}.zig", .{num});

    std.debug.print("Generating for day {d} under {s}\n", .{ day, file_name_buffer });
    try solutions_dir.writeFile(.{ .sub_path = &file_name_buffer, .data = &file_content_buffer });
}
