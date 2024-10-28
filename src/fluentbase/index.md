# Fluentbase Framework

Fluentbase is a framework offering an SDK and a proving system for Fluent STF.
Developers can leverage this framework to create shared applications (smart contracts), dedicated applications, system precompile contracts, or custom STFs.

> **WARNING: Don't use in production!**
>
> *Fluentbase is under experimental development and remains a work in progress. The bindings, methods, and naming conventions within the codebase are not yet standardized and may undergo significant changes. Furthermore, the codebase has not been audited or thoroughly tested, which could result in vulnerabilities or crashes.*

## Modules

- **`bin`**: Contains a binary application used for translating WASM-based applications to rWASM. Necessary only for creating system precompiled contracts requiring direct translation from WASM to rWASM.
- **`crates`**: Houses all Fluentbase modules:
  - **`codec`**: A custom ABI codec for encoding/decoding input messages, optimized for random reads to extract necessary information from the system context. It resembles Solidity ABI encoding but uses a more WASM-friendly binary encoding and alignment.
  - **`contracts`**: Includes all system precompiled contracts supporting different EE compatibilities like EVM, SVM, WASM, and system contracts (e.g., Blake2, SHA256).
  - **`core`**: The core for EE runtimes supporting EVM, SVM, and WASM, including deployment logic, AOT translation, and contract execution.
  - **`genesis`**: A program for creating genesis files for the Fluent L2 network with precompiled system and compatibility contracts.
  - **`poseidon`**: A library for Poseidon hashing.
  - **`runtime`**: The basic execution runtime of rWASM enabling Fluentbase’s host functions.
  - **`sdk`**: Provides all required types and methods for developing applications. Includes macros, entry points definitions, allocators, etc.
  - **`types`**: Basic primitive types for all crates within the repository.
  - **`zktrie`**: Implementation of zktrie (sparse Merkle binary trie).
- **`e2e`**: A set of end-to-end tests for testing EVM transition and other WASM features.
- **`revm`**: A fork of the revm crate, optimized and adapted for Fluentbase SDK methods, mapping the original revm's database objects into Fluentbase’s structures.
- **`examples`**: Contains examples that can be built using the Fluentbase SDK.

## Build and Testing

To build Fluentbase, a Makefile is available in the root folder that builds all required dependencies and examples.
Run the `make` command to build all contracts, examples, and genesis files.
The resulting files can be found in:
- **`crates/contracts/assets`**: WASM and rWASM binaries for all precompiled contracts and system contracts.
- **`crates/genesis/assets`**: Reth/geth compatible genesis files with injected rWASM binaries (used by reth).
- **`examples/*`**: Each folder contains `lib.wasm` and `lib.wat` files matching the compiled example bytecode.

For testing, the complete EVM official testing suite, which consumes significant resources, is included. Increase the Rust stack size to 20 MB for testing:

```bash
RUST_MIN_STACK=20000000 cargo test --no-fail-fast
```

**Note:** Some tests are still failing (e.g., zktrie), but 99% of them pass.

## Examples

Fluentbase SDK can be used to develop various applications, generally using the same interface. Below is a simple application developed using Fluentbase:

```rust
#![cfg_attr(target_arch = "wasm32", no_std)]
extern crate fluentbase_sdk;

use fluentbase_sdk::{basic_entrypoint, derive::Contract, SharedAPI};

#[derive(Contract)]
struct GREETING<SDK> {
  sdk: SDK,
}

impl<SDK: SharedAPI> GREETING<SDK> {
  fn deploy(&mut self) {
    // any custom deployment logic here
  }
  fn main(&mut self) {
    // write "Hello, World" message into output
    self.sdk.write("Hello, World".as_bytes());
  }
}

basic_entrypoint!(GREETING);
```

## Supported Languages

Fluentbase SDK currently supports writing smart contracts in:
- Rust
- Solidity
- Vyper

## Fluentbase Operation

Fluentbase operates using Fluent's rWASM VM (reduced WebAssembly).
This VM uses a 100% compatible WebAssembly binary representation optimized for Zero-Knowledge (ZK) operations.
The instruction set is reduced, with sections embedded inside the binary to simplify the proving process.

## Limitations and Future Enhancements

As of now, Fluentbase does not support floating-point operations.
However, this feature is on the roadmap for future enhancements.