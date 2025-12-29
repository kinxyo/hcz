const std = @import("std");
const hcz = @import("httpclientzig");

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(&buf);
    const allocator = fba.allocator();

    var server: hcz.Server = try .init(allocator);
    defer server.deinit();

    try server.request(.GET, "/", null);
    try server.request(.POST, "/msg", "{\"message\": \"hey\"}");
    try server.request(.POST, "/msg", .{ .message = "hey" });
}
