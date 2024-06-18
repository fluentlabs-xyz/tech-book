# Motivation

WebAssembly (WASM) is an interpreted language and binary format for Web2 (usually) developers.
Our approach describes how to let Web2 developers be transparently added into a Web3 world, but it's a bit challenging.
We like WASM comparing to RISC-V or other binary formats because of its well-known and mass-adopted standard
that developers like and support.
Also,
WASM has self-described binary format (including memory structure, type mapping and the rest)
compared to RISC-V/AMD/Intel binary formats that require some binary-wrappers like EXE or ELF.
But it doesn't mean that WASM is optimal,
it still has some tricky non ZK friendly structures that we'd like to avoid proving.
This is why we need rWASM.

rWASM (Reduced WebAssembly) is a special-modified binary IR (intermediary representation) of WASMi execution.
Literally, rWASM is 99% compatible with WASM's original bytecode and instruction set,
but with a modified binary structure w/o affecting opcode behavior.
The biggest WASM problem is relative offsets for type mappings, function mappings, and block/loop statements
(everything that relates to PC offsets).
rWASM binary format has more flattened structure w/o relative offsets, 
and rWASM doesn't require type mapping validator and must be executed as is.
Such a flattened structure makes it easier to proof the correctness of each opcode execution
and put several verification steps on the developer's hands.
