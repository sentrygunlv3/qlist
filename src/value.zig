pub const Value = union(enum) {
	int: i32,
	float: f32,
	bool: bool,
	string: []const u8,

	pub fn format(
		self: Value,
		writer: anytype,
	) !void {
		switch (self) {
			.int => |v| try writer.print("{d}", .{v}),
			.float => |v| try writer.print("{d}", .{v}),
			.bool => |v| try writer.print("{}", .{v}),
			.string => |v| try writer.print("\"{s}\"", .{v}),
		}
	}
};
