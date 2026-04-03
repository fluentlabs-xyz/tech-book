# Technology

This chapter summarizes the current rWASM technology model as implemented in `fluentlabs-xyz/rwasm`.

## High-level pipeline

rWASM uses a clear execution pipeline:

1. **Input Wasm module**
2. **Parser + validator**
3. **rWASM translator/compiler**
4. **Compact rWASM module artifact**
5. **Execution strategy** (native rWASM VM, plus optional compatibility strategy)

## Core subsystems

### Compiler / translator

The compiler layer parses and validates Wasm, then rewrites execution into the rWASM-oriented opcode stream and metadata layout.

### Module model

rWASM modules are serialized as explicit runtime artifacts consumed by the VM.
Current format includes a fixed header/magic + ordered sections (code/data/element/hints and source metadata).

### Opcode model

The opcode surface is explicitly defined and version-sensitive.

Important operational rule:
- opcode ordering and module encoding are wire-compatibility concerns,
- changing them is a format-level change, not a cosmetic refactor.

### Runtime VM

The native VM is a stack-machine executor with:

- value/call stack transitions,
- memory/table/global handling,
- trap model,
- host import linkage,
- resumable context hooks.

### Strategy abstraction

rWASM supports a strategy layer so native execution and compatibility/comparison backends can be selected by feature/runtime setup.

## Fuel and metering

Fuel is a first-class runtime primitive:

- bounded mode: deterministic out-of-fuel traps,
- unbounded mode: for controlled/testing contexts,
- reset/remaining behavior exposed by runtime store interfaces.

Fuel is consumed by both instruction paths and host-mediated operations depending on integration policy.

## Tracing and observability

With tracing enabled, runtime emits instruction/memory/table-oriented execution traces for debugging and analysis.

This is useful for:

- differential checks,
- profiling,
- proving/debug instrumentation.

## Feature-gated runtime surface

rWASM behavior depends on enabled features (`std`, `wasmtime`, `fpu`, `tracing`, etc.).
Feature combinations are part of the effective runtime surface and should be pinned in production builds.

## Security posture (architecture level)

Current rWASM docs emphasize:

- validation-first execution,
- fail-safe traps and bounds checks,
- host boundary determinism requirements,
- DoS controls via size/fuel/resource policies.

In practice, VM determinism and host determinism are both required.
A deterministic VM with nondeterministic host imports is still nondeterministic at system level.

## Implementation references

For exact, current behavior see:

- `rwasm/docs/architecture.md`
- `rwasm/docs/pipeline.md`
- `rwasm/docs/module-format.md`
- `rwasm/docs/vm-and-fuel.md`
- `rwasm/docs/opcodes.md`
- `rwasm/docs/security-considerations.md`
