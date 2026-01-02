const std = @import("std");
const h = @import("helpers.zig");
const io = @import("io.zig");
const p = std.posix;

pub const Server = @This();

fd: p.socket_t,
allocator: std.mem.Allocator,
buffer: [4096]u8 = undefined,
epoll_id: p.fd_t = undefined,
// flags
verbose: bool = false,

pub fn init(allocator: std.mem.Allocator) !Server {
    const sock_fd = try p.socket(p.AF.INET, p.SOCK.STREAM, 0);

    const addr: p.sockaddr.in = .{
        .port = std.mem.nativeToBig(u16, 8000),
        .addr = h.returnIp(.local),
    };

    try p.connect(sock_fd, @ptrCast(&addr), @sizeOf(@TypeOf(addr)));
    return .{
        .fd = sock_fd,
        .allocator = allocator,
    };
}

pub fn enableVerbose(self: *Server) void {
    self.verbose = true;
}

pub fn deinit(self: *const Server) void {
    p.close(self.fd);
}

pub fn request(
    self: *Server,
    comptime method: std.http.Method,
    comptime endpoint: []const u8,
    payload: anytype,
) !void {
    var req: []const u8 = undefined;

    if (@typeInfo(@TypeOf(payload)) == .null) {
        req = h.createRequest(method, endpoint);
    } else {
        req = try h.createRequestWith(
            self.allocator,
            method,
            endpoint,
            .json, // TODO: make this parameterized.
            payload,
        );
    }

    if (self.verbose) {
        std.log.info("Request:\n{s}\n", .{req});
    } else {
        io.log("\x1b[33m");
        io.logf("{s} {s}", .{ @tagName(method), endpoint });
        io.log("\x1b[0m");
        io.flush_log();
    }

    _ = try p.write(self.fd, req);

    try self.response();
}

fn response(self: *Server) !void {
    const bytes = try p.read(self.fd, &self.buffer);
    const data = self.buffer[0..bytes];

    if (self.verbose) {
        std.log.info("RESPONSE:{s}\n", .{data});
    } else {
        const i = std.mem.indexOf(u8, data, "\r\n\r\n") orelse return error.InvalidResponseFormat;
        const output = data[i + 2 ..];

        io.print("\x1b[97m");
        io.print(output[0 .. output.len - 1]);
        io.print("\x1b[0m");
        io.print("\n\n");
        io.flush();
    }

    @memset(&self.buffer, ' ');
}
