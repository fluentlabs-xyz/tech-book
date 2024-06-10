# Architecture

Fluent is a Layer 2 (L2) scaling solution designed to execute WebAssembly (WASM)-based applications, commonly referred to as smart contracts. It enhances scalability and efficiency by committing state changes to the Ethereum Layer 1 (L1) blockchain. This process involves compressing the state changes using ZK proofs (in particular, SNARKs).

![Fluent Arch](../images/fluent-arch.svg)

The architecture of Fluent L2 is designed to be as simple as possible. Only one VM (rWASM) and only one trie (Journaled ZK Trie) are supported. This means that Fluent doesnot interact with other VMs or EEs, including VM bytecode or ETH transaction types. Support for these environments is achieved through special system contracts known as Compatibility Contracts.

The simplest example of such a contract is an REVM state transition function. It takes Ethereum-compatible transactions, verifies signatures, and executes EVM bytecode. Compiling all these functions into WASM and rWASM, and running them directly is not super-efficient due to memory and storage costs. Therefore, versions of Compatibility Contracts (what we called blended executions) are developed to make these transitions more efficient for WASM.

Most chains require journals to execute transactions. Journals are the fastest and easiest way to store temporary information about executed transactions and semi-finalized states. They also support rollbacks in case of transaction failures. However, they require a lot of dynamically allocated memory to store this information. This issue is addressed by removing these journals and replacing them with the JZKT (Journaled ZK Trie) library, which simplifies the proving process for storing these journals.
