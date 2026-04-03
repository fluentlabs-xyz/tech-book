# rWASM

rWASM (reduced WebAssembly) is Fluent’s deterministic Wasm-derived execution representation and runtime stack.

It is designed for environments that care about:

- predictable execution behavior,
- explicit metering controls,
- proving-friendly structure.

## What rWASM is (and is not)

rWASM is **not** just a documentation alias for plain WebAssembly binaries.
It is a constrained execution model with:

- translation from Wasm inputs,
- a compact module format,
- a dedicated opcode/runtime model,
- host import/syscall integration boundaries.

At the same time, it keeps a Wasm-oriented developer path so existing tooling ecosystems remain practical.

## Current source of truth

For implementation-level details, use `fluentlabs-xyz/rwasm` docs first:

- architecture,
- pipeline,
- module format,
- VM/fuel behavior,
- opcode specification,
- security considerations.

This tech-book chapter summarizes architecture intent.

## Key architecture properties

1. **Deterministic execution model**
   - runtime semantics are designed for reproducible transitions.

2. **Compact module representation**
   - rWASM module encoding is structured for predictable runtime consumption.

3. **Host boundary clarity**
   - imports/syscalls are explicit integration points, not implicit ambient powers.

4. **Fuel-aware execution**
   - metering is a first-class runtime concern.

5. **Strategy abstraction**
   - native rWASM VM path and optional compatibility/backtesting strategy paths can coexist.

## Reading map

- [Motivation](motivation.md): why Fluent uses a reduced Wasm representation.
- [Technology](technology.md): architecture-level mechanics (pipeline, module format, VM/fuel, feature gates).
