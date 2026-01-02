//! Resusable helper functions.
const std = @import("std");

pub inline fn cmp(a: []const u8, comptime b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}
