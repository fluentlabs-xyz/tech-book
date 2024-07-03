# Architecture

Fluent is a Layer 2 (L2) scaling solution designed to execute WebAssembly (WASM)-based applications, commonly referred to as smart contracts. It enhances scalability and efficiency by committing state changes to the Ethereum Layer 1 (L1) blockchain. This process involves compressing the state changes using ZK proofs, specifically SNARKs.

![Fluent Architecture](../images/fluent-arch.svg)

## Simplified Design

The architecture of Fluent L2 is designed to be as simple as possible. It supports only one VM (rWASM) and one trie (Journaled ZK Trie). This means that Fluent does not directly interact with other VMs or EEs, including VM bytecode or ETH transaction types. Support for these environments is achieved through special system contracts known as Compatibility Contracts.

## Compatibility Contracts

An example of a Compatibility Contract is an REVM state transition function. This contract takes Ethereum-compatible transactions, verifies signatures, and executes EVM bytecode. Compiling all these functions into WASM and rWASM and running them directly can be inefficient due to memory and storage costs. Therefore, optimized versions of Compatibility Contracts, known as blended executions, have been developed to enhance efficiency for WASM.

## Journaled ZK Trie

Most blockchain platforms use journals to execute transactions. Journals are an efficient way to store temporary information about executed transactions and semi-finalized states, and they support rollbacks in case of transaction failures. However, they require significant dynamically allocated memory. Fluent addresses this issue by replacing traditional journals with the JZKT (Journaled ZK Trie) library, which simplifies the proving process and reduces memory requirements for storing these journals.