const std = @import("std");

const Argument = struct {
    isShort: bool,
    key: union {
        long: [:0]u8,
        short: u8,
    },
    hasValue: bool = false,
    value: [:0]u8 = "",
};

const ParseArgumentsError = error{
    InvalidArgument,
};

pub fn parseArguments(allocator: *std.mem.Allocator) !std.ArrayList(Argument) {
    var result = std.ArrayList(Argument).init(allocator);
    var argsIter = std.process.args();
    if (!argsIter.skip()) {
        @panic("launched with 0 arguments");
    }
    while (argsIter.next(stdalloc)) |rawArg| {
        const arg: [:0]u8 = rawArg catch "";
        if (arg[0] == '-' and arg[1] == '-' and arg.len > 2) {
            try result.append(.{ .isShort = false, .key = .{ .long = arg[2..] } });
        } else if (arg.len > 1 and arg[0] == '-') {
            // short arg(s)
            // this could be one: -a -> a
            // or multiple: -abc -> a, b, c
            for (arg[1..arg.len]) |c| {
                // TODO handle duplicate arguments?
                try result.append(.{ .isShort = true, .key = .{ .short = c } });
            }
        } else {
            if (result.items.len == 0) {
                std.log.err("invalid argument '{s}'.\n", .{arg});
                return ParseArgumentsError.InvalidArgument;
            } else {
                // assume its a value of the last argument
                if (result.items[result.items.len - 1].hasValue) {
                    std.log.err("expected argument, got value '{s}' to argument which already has a value.", .{arg});
                    return ParseArgumentsError.InvalidArgument;
                } else {
                    // it IS the value of the last argument
                    result.items[result.items.len - 1].value = arg;
                    result.items[result.items.len - 1].hasValue = true;
                }
            }
        }
    }
    return result;
}
