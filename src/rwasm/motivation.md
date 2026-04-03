# Motivation

WebAssembly gives Fluent a strong developer bridge: mature language support, broad tooling, and well-understood execution semantics.

But plain Wasm module/runtime assumptions are not automatically ideal for deterministic, proving-oriented blockchain execution.

## Problem Fluent is solving

If heterogeneous execution is handled as many isolated VM silos, proving and control-plane complexity grows quickly.

Fluent’s approach is to keep execution in one blended architecture and use rWASM as the Wasm-derived execution representation aligned with that model.

## Why Wasm-derived instead of machine ISA-first

Compared with low-level machine ISAs, Wasm offers:

- better developer ecosystem reach,
- cleaner portability story,
- structured semantics that can be translated/constrained for deterministic execution.

rWASM keeps these advantages while reshaping representation where needed for runtime determinism and proof ergonomics.

## What rWASM changes conceptually

At architecture level, rWASM aims to reduce execution-representation friction by:

- flattening/normalizing control-flow and metadata patterns where useful,
- reducing dependence on runtime-heavy mapping layers,
- making module/runtime boundaries explicit.

The objective is not “invent a new language,” but to make Wasm-family execution easier to govern and verify in Fluent’s protocol context.

## Expected outcome

rWASM helps Fluent combine:

- Wasm-friendly developer onboarding,
- deterministic host/runtime coordination,
- proving-oriented execution structure.

That combination is why rWASM is central to Fluent’s blended execution design.
