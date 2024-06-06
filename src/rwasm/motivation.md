# Motivation

WebAssembly (WASM) is an interpreted language and binary format for Web2 (usually) developers.
Our approach describes how to let Web2 developers to be transparently added into Web3 world, although it presents some challenges.
We prefer WASM comparing to RISC-V or other binary formats due to its well-known, widely adopted standard that developers appreciate and support.
Additionally, WASM includes a self-described binary format (covering memory structure, type mapping, and more) compared to RISC-V/AMD/Intel binary formats, which require some binary-wrappers like EXE or ELF.
However, it does not mean that WASM is optimal, it still has some tricky non-ZK friendly structures that we would like to avoid to prove.
This is why we need rWASM.

rWASM (Reduced WebAssembly) is a special-modified binary IR (intermediary representation) of WASMi execution.
Literally rWASM is 99% compatible with WASM original bytecode and instruction set, but with a modified binary structure w/o affecting opcode behaviour.
The biggest WASM problem is relative offsets for type mappings, function mappings and block/loop statements (everything that relates to PC offsets).
rWASM binary format has more flatten structure w/o relative offsets and rWASM doesn't require type mapping validator and must be executed as is.
Such flatten structure makes easier to proof correctness of each opcode execution and put several verification steps on developer's hands.
