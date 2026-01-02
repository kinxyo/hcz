const std = @import("std");
const hcz = @import("httpclientzig");
const utils = @import("utils.zig");
const cmp = utils.cmp;

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(&buf);
    const allocator = fba.allocator();

    var args = std.process.args();
    _ = args.skip();

    var server: hcz.Server = try .init(allocator);
    defer server.deinit();

    if (args.next()) |arg| {
        if (cmp(arg, "-v")) server.enableVerbose();
    }

    try server.request(.GET, "/", null);
    try server.request(.POST, "/msg", "{\"message\": \"hey\"}");
    try server.request(.POST, "/msg", .{ .message = "hey" });
}
