# Architecture

Fluent is a Layer 2 (L2) scaling solution designed to execute WebAssembly-based applications,
commonly referred to as smart contracts.
It enhances scalability and efficiency by committing state changes to the Ethereum L1 blockchain.
This process involves compressing the state changes using ZK proofs, specifically SNARK(s).

![Fluent Architecture](../images/fluent-arch.svg)

*The image illustrates the base architecture of Fluent L2*

Fluent L2 operates on a modified version of Reth, using its own execution engine that replaces Revm.
It maintains backward compatibility with most existing Ethereum standards, such as transaction and block structures.
However, Fluent is not confined to Reth exclusively, as it boasts an independent execution runtime.

Furthermore,
Fluent enables a fork-less runtime upgrade model
by incorporating the most critical and upgradable runtime execution codebase within the genesis state.
The only persistent element within the runtime is the transaction format.

Additionally, Fluent is always post-Cancun and does not support any EIPs implemented before the Cancun fork.
Maintaining backward compatibility with all previous forks is unnecessary.
The EVM runtime can be upgraded to support the most relevant EIP standards.

## Blended Execution

The core of Fluent is founded on the Blended Execution approach.
This concept is employed to create an intermediary representation (IR) for executable applications.

Executable applications can encompass smart contracts,
execution environment (EE) simulations, or state transition functions.
More broadly, Blended Execution is used to define various types of state transitions.

For instance:
- An EVM application specifies EVM opcode transitions.
- A WASM application specifies WASM opcode transitions.

In essence,
Blended Execution provides a versatile framework for defining state transitions in a wide range of applications.

To create a Zero-Knowledge (ZK) proof, developers need to extract a trace to represent all these transitions.
We use the rWASM (reduced-WebAssembly) language to define such trace transitions.
Fluentbase framework is our development toolkit for creating WebAssembly applications.

### rWASM

rWASM is a binary Intermediate Representation (IR) designed for computations.
It converts WebAssembly (WASM) into rWASM,
where the majority of operations and segments are represented in a simplified and more zero-knowledge
(ZK)-friendly format.

rWASM is used to represent the execution trace of all operations within Fluent L2.
To achieve this, we compile as much as possible into rWASM IR,
ensuring that every operation can be consistently represented using the same trace language.
Additionally, we develop rWASM zkVM circuits to verify all state transitions conclusively.

You can read more about rWASM architecture and structure in the [corresponding section](./rwasm/index.md).

### Fluentbase

Fluentbase is a comprehensive framework, or monorepo,
equipped with essential tools for creating and running WebAssembly and rWASM-based applications.
More broadly, Fluentbase serves as an SDK, providing crucial type mappings and bindings necessary for app development.

You can read more about Fluentbase architecture and structure in the [corresponding section](./fluentbase/index.md).

### Blended VM

Blended VM is a concept that uses both Fluentbase Framework and rWASM technologies.
rWASM is used as an execution runtime that takes rWASM binary as an input.
Inside Fluentbase Runtime there is no such thing as state, it can operate with stateless operations only.
For example, you can't access database objects directly.
Instead,
we provide an interruption system
that can be used to interrupt program execution to request root-STF to provide missing state data.

The main goal of **Blended VM** that always uses only one first-citizen language under the hood is rWASM.
Having only one VM inside the state, transition makes proving much easier and faster.
In this case, compatibility with other EE/VM(s)
can be achieved though special AOT (Ahead-of-Time) compilers or simulation contracts.

Developers can achieve execution environment (EE) compatibility
(such as EVM or SVM) through specially designed rWASM-based system contracts.
For instance, the EVM is implemented using a special EVM-proxy,
which delegates the execution of EVM contracts to a dedicated system pre-compile that supports EVM opcodes.

This same goal can be achieved by creating an EVM deployer that translates EVM bytecode into an rWASM application.
Similarly, by following this approach,
developers can create their own EE contracts and support custom virtual machines (VMs)
with complete execution environments by implementing a specialized RPC proxy mapper.

![Fluent Architecture](../images/rpc-ee.svg)

*The image illustrates how the RPC relayer maps user operations to match a specific execution environment*

By using this approach,
we can support different EE
by implementing AOT compilers or just running EE simulation software that can be compiled down into WASM (rWASM).

## Execution Environment

Fluent L2 is built upon an Ethereum transaction type.
Achieving support for different Execution Environments (EE) can vary significantly based on numerous factors.
These factors include the type of cryptography used (particularly when a raw transaction is processed),
the percentage of compatible features, and the address format.

### Problems and Solutions

1. **Incompatible Cryptography**: Execution Environments (EE) can consume an entire transaction as an input, requiring the use of system bindings to verify signature correctness. Fluent supports pre-compiles for a range of commonly used cryptographic functions (e.g., secp256k1, ed25519, bn254, bls384). For any missing cryptographic functions, you can implement them as custom precompiled contracts.

2. **Different Address Format**: Fluent uses an Ethereum-compatible 20-byte address format. If an address uses a different derivation format or has more bytes than a contract can store, there needs to be a way to handle this. Such addresses can be stored as so-called projected addresses, which are calculated using any hashing function. Account information can then be stored inside the storage mapping of the EE account.

3. **Custom Bytecode Storage**: There is a need to store immutable data like custom bytecode. Fluent provides a preimage database that can be used to store immutable data, including custom bytecode or other data. 

### Fully Compatible EE

Full EE compatibility is possible by running the entire EE runtime as a smart contract.
This is the easiest way to achieve EE compatability.