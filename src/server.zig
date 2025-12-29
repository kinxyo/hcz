const std = @import("std");
const h = @import("helpers.zig");
const p = std.posix;

pub const Server = struct {
    fd: p.socket_t,
    allocator: std.mem.Allocator,
    buffer: [4096]u8 = undefined,

    pub fn init(allocator: std.mem.Allocator) !Server {
        const sock_fd = try p.socket(p.AF.INET, p.SOCK.STREAM, 0);
        std.log.info("socket created!", .{});

        const addr: p.sockaddr.in = .{
            .port = std.mem.nativeToBig(u16, 8000),
            .addr = h.returnIp(.local),
        };

        try p.connect(sock_fd, @ptrCast(&addr), @sizeOf(@TypeOf(addr)));
        std.log.info("socket connected!", .{});
        return .{
            .fd = sock_fd,
            .allocator = allocator,
        };
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
            req = try h.createRequestWithPayload(
                self.allocator,
                method,
                endpoint,
                .json, // TODO: make this parameterized.
                payload,
            );
        }

        std.log.info("Request:\n{s}\n", .{req});

        _ = try p.write(self.fd, req);

        try self.response();
    }

    fn response(self: *Server) !void {
        const bytes = try p.read(self.fd, &self.buffer);
        std.log.info("Response:\n{s}\n", .{self.buffer[0..bytes]});
        @memset(&self.buffer, ' ');
    }
};
