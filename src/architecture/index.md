# Architecture

Fluent is a L2 for executing WASM-based applications (aka smart contracts) and commits state changes into Ethereum L1 by compressing them using ZK.

![Fluent Arch](../images/fluent-arch.svg)

The architecture of Fluent L2 is designed to be as simple as possible. Only one VM (rWASM) and only one trie (Journaled ZK Trie) are supported. This means that Fluent doesn’t interact with other VMs or EEs, including VM bytecode or ETH transaction types. Support for these environments is achieved through special system contracts known as Compatibility Contracts.

The simplest example of such a contract is an REVM state transition function. It takes Ethereum-compatible transactions, verifies signatures, and executes EVM bytecode. Compiling all these functions into WASM and rWASM and running them directly is not super efficient due to memory and storage costs. Therefore, versions of Compatibility Contracts are developed to make these transitions more efficient for WASM.

Most chains require journals to execute transactions. Journals are the fastest and easiest way to store temporary information about executed transactions and semi-finalized states. They also support rollbacks in case of transaction failures. However, they require a lot of dynamically allocated memory to store this information. This issue is addressed by removing these journals and replacing them with the JZKT (Journaled ZK Trie) library, which simplifies the proving process for storing these journals.

