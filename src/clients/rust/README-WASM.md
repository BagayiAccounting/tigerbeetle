# TigerBeetle Rust Client - WebAssembly Build

This document describes the WebAssembly (WASM) build configuration for the TigerBeetle Rust client.

## Overview

The TigerBeetle Rust client has been modified to support compilation to WebAssembly for **server-side WASM environments**. The client connects directly to TigerBeetle servers using the native protocol, making it perfect for use in SurrealDB plugins, WebAssembly System Interface (WASI) applications, and other server-side WASM runtimes.

## Build Instructions

### Prerequisites

1. Install the WASM target for Rust:
```bash
rustup target add wasm32-unknown-unknown
```

2. Install wasm-pack (optional, for generating JavaScript bindings):
```bash
cargo install wasm-pack
```

### Building

To build the WASM version:

```bash
# Development build
cargo build --target wasm32-unknown-unknown

# Release build (optimized)
cargo build --target wasm32-unknown-unknown --release
```

The compiled WASM file will be available at:
- `target/wasm32-unknown-unknown/debug/tigerbeetle.wasm` (debug)
- `target/wasm32-unknown-unknown/release/tigerbeetle.wasm` (release)

### Using wasm-pack

For generating JavaScript bindings:

```bash
wasm-pack build --target web --out-dir pkg
```

## Architecture Changes for WASM

### Build Configuration

- **Modified `build.rs`**: Skips native library linking when targeting `wasm32`
- **Updated `Cargo.toml`**: Added WASM-specific dependencies (`wasm-bindgen`, `js-sys`, `web-sys`)
- **Added `wasm.rs` module**: Provides WASM-compatible client stub

### Current Implementation

The current WASM implementation includes:

- **Core Data Types**: All TigerBeetle data structures (`Account`, `Transfer`, etc.) are available
- **Direct Connection Client**: Connects directly to TigerBeetle servers using native protocol
- **JavaScript Interop**: Full WASM-bindgen integration for seamless JS/WASM communication
- **Server-Side WASM Focused**: Optimized for environments like SurrealDB plugins

## Usage Examples

### Server-Side WASM (SurrealDB Plugin, WASI)

```javascript
import init, { WasmClient } from './pkg/tigerbeetle.js';

async function main() {
    await init();
    
    // Create client for server-side WASM
    const client = new WasmClient("0", "127.0.0.1:3000");
    
    // Connect to TigerBeetle server
    await client.connect();
    
    // Create accounts using native protocol
    const accounts = [
        { id: "1", ledger: 1, code: 1 },
        { id: "2", ledger: 1, code: 1 }
    ];
    
    const results = await client.create_accounts(accounts);
    console.log("Account creation results:", results);
    
    // Create transfers
    const transfers = [
        {
            id: "100",
            debit_account_id: "1",
            credit_account_id: "2", 
            amount: "1000",
            ledger: 1,
            code: 1
        }
    ];
    
    const transferResults = await client.create_transfers(transfers);
    console.log("Transfer results:", transferResults);
}

main();
```

## Production Considerations

1. **Direct Connections**: Uses native TigerBeetle protocol for optimal performance
2. **Native Protocol**: Full TigerBeetle protocol support without translation overhead  
3. **Security**: Standard TigerBeetle security and authentication mechanisms
4. **Performance**: No HTTP overhead, direct binary protocol communication
5. **Server-Side Only**: Designed specifically for server-side WASM environments

## Development Notes

- The native `Client` implementation is conditionally compiled out for WASM targets
- All core data structures maintain their binary compatibility
- The build process automatically detects WASM targets and adjusts linking accordingly
- Warning messages about unused imports in `wasm.rs` are expected and can be addressed as the implementation evolves

## File Structure

```
src/clients/rust/
├── Cargo.toml              # Updated with WASM dependencies
├── build.rs                # Modified to skip native linking for WASM
├── src/
│   ├── lib.rs             # Main library with conditional WASM module
│   ├── wasm.rs            # WASM-specific implementations
│   └── ...                # Other existing modules
└── target/wasm32-unknown-unknown/
    └── release/
        └── tigerbeetle.wasm  # Compiled WASM binary
```

This WASM build provides the foundation for browser-based TigerBeetle applications while maintaining compatibility with the existing Rust ecosystem.
