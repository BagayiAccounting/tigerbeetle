//! WASM-specific entry point for exporting the `tb_client` library.
//! This version doesn't require libc and exports functions compatible with WASM.
const builtin = @import("builtin");
const std = @import("std");

pub const vsr = @import("vsr");
const exports = vsr.tb_client.exports;

pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = exports.Logging.application_logger,
};

comptime {
    // For WASM, we don't require libc
    if (builtin.target.cpu.arch != .wasm32) {
        @compileError("This module is only for WASM targets. Use libtb_client.zig for other targets.");
    }

    // Export functions with WASM-compatible signatures
    @export(&wasm_init, .{ .name = "tb_client_init", .linkage = .strong });
    @export(&wasm_init_echo, .{ .name = "tb_client_init_echo", .linkage = .strong });
    @export(&wasm_submit, .{ .name = "tb_client_submit", .linkage = .strong });
    @export(&wasm_deinit, .{ .name = "tb_client_deinit", .linkage = .strong });
    @export(&wasm_completion_context, .{ .name = "tb_client_completion_context", .linkage = .strong });
}

// WASM-compatible wrapper functions
fn wasm_init(
    client_out: *exports.tb_client_t,
    cluster_id_ptr: *const [16]u8,
    address_ptr: [*]const u8,
    address_len: u32,
    completion_ctx: usize,
    completion_callback: ?*const fn (usize, *exports.tb_packet_t, u64, [*]const u8, u32) callconv(.C) void,
) callconv(.C) exports.tb_init_status {
    return exports.init(client_out, cluster_id_ptr, address_ptr, address_len, completion_ctx, completion_callback);
}

fn wasm_init_echo(
    client_out: *exports.tb_client_t,
    cluster_id_ptr: *const [16]u8,
    address_ptr: [*]const u8,
    address_len: u32,
    completion_ctx: usize,
    completion_callback: ?*const fn (usize, *exports.tb_packet_t, u64, [*]const u8, u32) callconv(.C) void,
) callconv(.C) exports.tb_init_status {
    return exports.init_echo(client_out, cluster_id_ptr, address_ptr, address_len, completion_ctx, completion_callback);
}

fn wasm_submit(client: ?*exports.tb_client_t, packet: *exports.tb_packet_t) callconv(.C) exports.tb_client_status {
    return exports.submit(client, packet);
}

fn wasm_deinit(client: ?*exports.tb_client_t) callconv(.C) exports.tb_client_status {
    return exports.deinit(client);
}

fn wasm_completion_context(client: ?*exports.tb_client_t, completion_ctx_out: *usize) callconv(.C) exports.tb_client_status {
    return exports.completion_context(client, completion_ctx_out);
}
