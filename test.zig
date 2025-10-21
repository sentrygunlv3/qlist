const std = @import("std");
const print = std.debug.print;

const ql = @import("src/lib.zig");

pub fn main() !void {
	var gpa = std.heap.GeneralPurposeAllocator(.{}){};
	const allocator = gpa.allocator();

	var state = ql.QList.init(allocator);
	defer state.deinit();

	ql.read(&state, "./example.qls")  catch |e| {
		print("{}\n", .{e});
		return;
	};

	var iterator = state.hm.iterator();
	while (iterator.next()) |item| {
		print("{s} = {f}\n", .{ item.key_ptr.*, item.value_ptr.* });
	}
}
