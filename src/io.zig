const std = @import("std");

var buf_w: [1024 * 4]u8 = undefined;
var writer = std.fs.File.stdout().writer(&buf_w);
const stdout = &writer.interface;

var buf_e: [1024 * 4]u8 = undefined;
var writer_err = std.fs.File.stderr().writer(&buf_e);
const stderr = &writer_err.interface;

pub fn flush() void {
    stdout.flush() catch {};
}

pub fn print(bytes: []const u8) void {
    stdout.writeAll(bytes) catch {};
}

pub fn printf(comptime fmt: []const u8, args: anytype) void {
    stdout.print(fmt, args) catch {};
}

pub fn flush_log() void {
    stderr.flush() catch {};
}

pub fn log(bytes: []const u8) void {
    stderr.writeAll(bytes) catch {};
}

pub fn logf(comptime fmt: []const u8, args: anytype) void {
    stderr.print(fmt, args) catch {};
}
