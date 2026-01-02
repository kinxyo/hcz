//! Inside layer or implementation for Server struct;
//! functions that dont require instance.
const std = @import("std");

const ipType = enum {
    local,
    localExposed,
    google,
};

pub fn returnIp(comptime ip: ipType) u32 {
    const array: [4]u8 = switch (ip) {
        .local => .{ 127, 0, 0, 1 },
        .localExposed => .{ 192, 168, 1, 100 },
        .google => .{ 142, 250, 185, 46 },
    };
    return @bitCast(array);
}

pub fn createRequest(
    comptime method: std.http.Method,
    comptime endpoint: []const u8,
) []const u8 {
    return std.fmt.comptimePrint("{s} {s} HTTP/1.1\r\n", .{ @tagName(method), endpoint }) ++
        "Host: locahost:8000\r\n" ++
        "User-Agent: CustomZigClientHttp\r\n" ++
        "Accept: */*\r\n" ++
        "\r\n";
}

const contentType = enum {
    text,
    json,
    form,

    fn returnString(self: contentType) []const u8 {
        return switch (self) {
            .text => "application/text",
            .json => "application/json",
            .form => "application/x-www-form-urlencoded",
        };
    }
};

pub fn createRequestWith(
    allocator: std.mem.Allocator,
    method: std.http.Method,
    endpoint: []const u8,
    ct: contentType,
    payload: anytype,
) ![]const u8 {
    const body = switch (@typeInfo(@TypeOf(payload))) {
        .@"struct" => try std.json.Stringify.valueAlloc(allocator, payload, .{ .whitespace = .indent_2 }),
        else => payload,
    };

    return try std.fmt.allocPrint(
        allocator,
        "{s} {s} HTTP/1.1\r\n" ++
            "Host: locahost:8000\r\n" ++
            "User-Agent: CustomZigClientHttp\r\n" ++
            "Accept: */*\r\n" ++
            "Content-Type: {s}\r\n" ++
            "Content-Length: {d}\r\n" ++
            "\r\n" ++
            "{s}",
        .{ @tagName(method), endpoint, ct.returnString(), body.len, body },
    );
}
