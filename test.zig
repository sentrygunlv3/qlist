const std = @import("std");
const print = std.debug.print;

const ql = @import("src/lib.zig");

pub fn main() !void {
    var state = ql.QList.init();
    defer state.deinit();

    ql.read(&state, "./example.ql")  catch |e| {
        print("{}\n", .{e});
		return;
	};

	var iterator = state.hm.iterator();
	while (iterator.next()) |item| {
		print("{s} = {f}\n", .{ item.key_ptr.*, item.value_ptr.* });
	}
}
