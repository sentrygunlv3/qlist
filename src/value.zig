const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error{
	InvalidType,
	NameParseError,
	InvalidLineCount,
};

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

pub const QList = struct {
	allocator: Allocator,
	hm: std.StringHashMap(Value),

	pub fn init(allocator: Allocator) QList {
		return .{
			.allocator = allocator,
			.hm = std.StringHashMap(Value).init(allocator),
		};
	}

	pub fn deinit(self: *QList) void {
		var iterator = self.hm.iterator();
		while (iterator.next()) |item| {
			self.allocator.free(item.key_ptr.*);
		}
		self.hm.deinit();
	}
};
