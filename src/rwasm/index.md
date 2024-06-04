# rWASM

rWASM (reduced WebAssembly) is an EIP-3540 compatible binary IR (intermediary representation) of WASM (WebAssembly) that is used to simplify execution process of WASM binaries by keeping 100% compatibility with original WASM features.

It achieves ZK-friendliness by having more flatten binary structure and simplified instruction set.

IMPORTANT: rWASM is a trusted execution runtime, don't run it w/o validation.
It's safe to translate WASM to rWASM and execute since it injects all validations inside entrypoint. 