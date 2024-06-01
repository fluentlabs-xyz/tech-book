# Architecture

Fluent is a L2 for executing WASM-based applications (aka smart contracts) and commits state changes into Ethereum L1 by compressing them using ZK.

The architecture of Fluent L2 is designed to be as simple as possible. We support only one VM (that is rWASM) and only one trie (Journaled ZK Trie). It means that Fluent doesn’t know anything about other VMs or EEs, including VM bytecode or ETH transaction type. We achieve support of these environments by having special system contracts so-called Compatibility Contracts.

The simplest example of such a contract is an REVM state transition function. It takes Ethereum compatible transactions, verifies signatures and executes EVM bytecode. It's not super efficient to just compile all these functions into WASM and rWASM and run because of memory and storage costs, so we develop our versions of Compatibility Contracts to make these transitions more efficient for WASM.

Most chains require journals to execute transactions. It's the fastest and easiest way to store temporary information about executed transactions and semi-finalized states. Also it brings support of rollback in case of transaction failures. But it requires a lot of dynamically allocated memory to store this information. We remove these journals and replace them with our JZKT (journaled trie) library that simplifies the proving process for storing these journals.