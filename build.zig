const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("zig-args", "src/args.zig");
    lib.setBuildMode(mode);
    lib.install();
}
