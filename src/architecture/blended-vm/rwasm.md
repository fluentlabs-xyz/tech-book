# rWasm

rWasm is Fluent’s Wasm-derived execution substrate inside the blended VM architecture.

Its role is to make heterogeneous execution more deterministic and proving-friendly while preserving a practical Wasm developer path.

## Architectural role in Fluent

In Fluent’s blended model, rWasm is the execution representation that helps unify runtime behavior across different integration paths.

At system level, this supports:

- one shared state-transition model,
- host-governed interruption/syscall boundaries,
- deterministic commit semantics.

## Why rWasm instead of plain Wasm modules everywhere

Plain Wasm is developer-friendly but includes representation/runtime assumptions that are not always ideal for protocol-grade deterministic/proving workflows.

rWasm addresses this by using:

- a constrained translation/execution model,
- explicit module/runtime boundaries,
- a dedicated opcode/runtime surface designed for predictable behavior.

## Current implementation shape (from `fluentlabs-xyz/rwasm`)

### 1) Translation pipeline

Wasm input is validated and translated into a compact rWasm module consumed by the runtime.

### 2) Module encoding contract

rWasm modules use explicit header/versioning and ordered sections.
This is treated as compatibility-sensitive wire format.

### 3) Runtime VM + strategy layer

The runtime includes a native VM executor and a strategy abstraction for optional compatibility/comparison execution backends.

### 4) Fuel-first metering

Fuel limits and consumption are explicit runtime controls, including deterministic out-of-fuel behavior.

### 5) Optional tracing

Tracing can capture execution/memory/table events for debugging and analysis pipelines.

## Determinism and security boundary

rWasm determinism depends on both:

- VM semantics, and
- host import/syscall behavior.

So runtime correctness requires deterministic host integration, not only deterministic opcode dispatch.

## Status notes for readers

- rWasm docs evolve with implementation; treat exact opcode and module-format details as version-sensitive.
- For current production behavior, consult `fluentlabs-xyz/rwasm/docs/*` plus active Fluentbase/reth release docs.
