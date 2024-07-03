# Fluentbase

Fluentbase is a framework that provides an SDK and a proving system for Fluent State Transition Functions (STF).
Developers can use this framework to create shared applications (smart contracts),
dedicated applications, system precompile contracts, or custom STFs.

## Don't Use in Production

Fluentbase is still in experimental development and is a work in progress.
The bindings, methods,
and naming conventions within the codebase are not standardized and are subject to significant changes.
Additionally, the codebase has not been audited or fully tested, potentially leading to vulnerabilities or crashes.

## Modules

- **`bin`**: A crate with a binary application used for translating WASM-based applications to rWASM. It is required only for creating system precompiled contracts where direct translation from WASM to rWASM is necessary.
- **`crates`**: Folder containing all Fluentbase modules.
    - **`codec`**: A custom ABI codec for encoding/decoding input messages. This codec is optimized for random reads to extract only the necessary information from the passed system context. It is similar to Solidity ABI encoding but uses a more WASM-friendly binary encoding and alignment.
    - **`contracts`**: A crate with all system precompiled contracts supporting different EE compatibilities, including EVM, SVM, WASM, and system contracts like Blake2, SHA256, etc.
    - **`core`**: The core of EE runtimes supporting EVM, SVM, and WASM, including deployment logic, AOT translation, and contract execution.
    - **`evm` (outdated)**: Repository with the EVM AOT compiler.
    - **`genesis`**: A program for creating genesis files for the Fluent L2 network with precompiled system and compatibility contracts.
    - **`poseidon`**: A library for Poseidon hashing.
    - **`revm` (migrating)**: A fork of the revm crate, optimized and adapted for Fluentbase SDK methods and maps the original revm's database objects into Fluentbase’s structures. It is needed to execute EVM transactions inside reth.
    - **`runtime`**: The basic execution runtime of rWASM that enables Fluentbase’s host functions.
    - **`sdk`**: A repository for developers to include all required types and methods to develop their applications. It includes macros, definitions of entry points, allocators, etc.
    - **`types`**: Basic primitive types for all crates inside this repository.
    - **`zktrie`**: Implementation of zktrie (sparse Merkle binary trie).
- **`e2e` (partially outdated)**: A set of end-to-end tests for testing EVM transition and other WASM features.
- **`examples`**: A folder with examples that can be built using the Fluentbase SDK.

## Build and Testing

To build Fluentbase, there is a Makefile in the root folder that builds all required dependencies and examples.
You can run the `make` command to build all contracts, examples, and genesis files.

The resulting files can be found in the following directories:

- **`crates/contracts/assets`**: WASM and rWASM binaries for all precompiles, system contracts, and compatibility contracts.
- **`crates/genesis/assets`**: Reth/geth compatible genesis files with injected rWASM binaries (used by reth).
- **`examples/*`**: Each folder contains `lib.wasm` and `lib.wat` files that match the compiled example bytecode.

Testing includes the complete EVM official testing suite, which consumes a lot of resources.
It is recommended to increase the Rust stack size to 20 MB.

```bash
RUST_MIN_STACK=20000000 cargo test --no-fail-fast
```

**Note:** Some tests are still failing (e.g., zktrie), but 99% of them pass.

## Examples

Fluentbase SDK can be used to develop various types of applications, mostly using the same interface.
Here is a simple application developed using Fluentbase:

```rust
#![cfg_attr(target_arch = "wasm32", no_std)]
extern crate fluentbase_sdk;

use fluentbase_sdk::{basic_entrypoint, SharedAPI};

#[derive(Default)]
struct GREETING;

impl GREETING {
    fn deploy<SDK: SharedAPI>(&self) {
        // custom deployment logic here
    }
    fn main<SDK: SharedAPI>(&self) {
        // write "Hello, World" message into output
        SDK::write("Hello, World".as_bytes());
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
The instruction set is reduced, and sections are embedded inside the binary to simplify the proving process.

## Limitations and Future Enhancements

As of now, Fluentbase does not support floating-point operations.
However, this feature is on the roadmap for future enhancements.