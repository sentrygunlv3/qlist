const std = @import("std");
const print = std.debug.print;

const Value = @import("value.zig").Value;

const Error = error{
    InvalidType,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub const QList = struct {
	hm: std.StringHashMap(Value),

	pub fn init() QList {
		return .{
			.hm = std.StringHashMap(Value).init(allocator),
		};
	}

	pub fn deinit(self: *QList) void {
		var iterator = self.hm.iterator();
		while (iterator.next()) |item| {
			allocator.free(item.key_ptr.*);
		}
		self.hm.deinit();
	}
};

pub fn read(ql: *QList, path: []const u8) !void {
	var file = std.fs.cwd().openFile(path, .{}) catch {
		return;
	};
	defer file.close();

	var reader = file.deprecatedReader();
	var buffer: [1024]u8 = undefined;

	while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
		if (line.len < 1) continue;
		//print("{s}\n", .{line});
		const first_char = line[0];
		switch (first_char) {
			'/' => continue,
			'i' => {
				const name = parse_name(line) catch {
					return;
				};

				try ql.hm.put(name, .{.int = 300});
			},
			'f' => {
				const name = parse_name(line) catch {
					return;
				};

				try ql.hm.put(name, .{.float = 300.5});
			},
			's' => {
				const name = parse_name(line) catch {
					return;
				};

				try ql.hm.put(name, .{.string = "hello"});
			},
			'b' => {
				const name = parse_name(line) catch {
					return;
				};

				try ql.hm.put(name, .{.bool = true});
			},
			else => return Error.InvalidType
		}
	}
}

fn parse_name(str: []const u8) ![]const u8 {
	if (str.len <= 2) return "";

	const end = str[2..];
	//print("  {s}\n", .{end});

	if (std.mem.indexOfScalar(u8, end, ' ')) |pos| {
		//print("  {s}\n", .{end[0..pos]});
		const name = end[0..pos];
		return try allocator.dupe(u8, name);
	} else {
		return end;
	}
}
