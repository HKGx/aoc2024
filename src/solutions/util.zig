pub fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        pub fn add(self: @This(), other: @This()) @This() {
            return .{ .x = self.x + other.x, .y = self.y + other.y };
        }

        pub fn addMut(self: *@This(), other: @This()) void {
            self.x += other.x;
            self.y += other.y;
        }
    };
}
