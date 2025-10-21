const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const Value = @import("value.zig").Value;

const Error = error{
	InvalidType,
	NameParseError,
	InvalidLineCount,
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

pub fn read(ql: *QList, path: []const u8) !void {
	var file = std.fs.cwd().openFile(path, .{}) catch |e| {
		return e;
	};
	defer file.close();

	var reader = file.deprecatedReader();
	var buffer: [1024]u8 = undefined;

	while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
		if (line.len < 1) continue;
		//print("{s}\n", .{line});
		const first_char = line[0];
		var pos: usize = 0;
		switch (first_char) {
			'/' => continue,
			'i' => {
				const name = parse_name(ql, &pos, line) catch |e| return e;
				const line_end = line[pos..];

				const value = try std.fmt.parseInt(i32, line_end, 10);

				try ql.hm.put(name, .{.int = value});
			},
			'f' => {
				const name = parse_name(ql, &pos, line) catch |e| return e;
				const line_end = line[pos..];

				const value = try std.fmt.parseFloat(f32, line_end);

				try ql.hm.put(name, .{.float = value});
			},
			's' => {
				const name = parse_name(ql, &pos, line) catch |e| return e;
				const line_end = line[pos..];

				try ql.hm.put(name, .{.string = try ql.allocator.dupe(u8, line_end)});
			},
			'S' => {
				const name = parse_name(ql, &pos, line) catch |e| return e;
				const line_end = line[pos..];
				const line_count = try std.fmt.parseInt(i32, line_end, 10);

				var value = try std.ArrayList(u8).initCapacity(ql.allocator, 0);
				defer value.deinit(ql.allocator);

				var i: i32 = 0;
				while (i < line_count) : (i += 1) {
					if (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |next_line| {
						try value.appendSlice(ql.allocator, next_line);
						if (i != line_count - 1) {
							try value.appendSlice(ql.allocator, "\n");
						}
					} else {
						return Error.InvalidLineCount;
					}
				}

				try ql.hm.put(name, .{.string = try ql.allocator.dupe(u8, try value.toOwnedSlice(ql.allocator))});
			},
			'b' => {
				const name = parse_name(ql, &pos, line) catch |e| return e;
				const line_end = line[pos..];

				var value = false;
				if (line_end[0] == 't') {
					value = true;
				}

				try ql.hm.put(name, .{.bool = value});
			},
			else => return Error.InvalidType
		}
	}
}

fn parse_name(ql: *QList, pos: *usize, str: []const u8) ![]const u8 {
	if (str.len <= 2) return Error.NameParseError;

	const slice = str[2..];

	if (std.mem.indexOfScalar(u8, slice, ' ')) |end| {
		const name = slice[0..end];
		pos.* = end + 3;
		return try ql.allocator.dupe(u8, name);
	} else {
		return Error.NameParseError;
	}
}
