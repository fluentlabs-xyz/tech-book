# Architecture

Fluent is an Ethereum Layer 2 (L2) rollup designed to natively execute EVM, SVM and Wasm-based programs.
Fluent exists as a unified state machine,
where all contracts can call each other, regardless of which VM they were originally built for.

As a rollup, Fluent supports scalable and efficient execution by committing state changes to Ethereum L1.
This process involves compressing the state changes using ZK proofs, specifically SNARKs.

<p align="center">
   <img src="../images/fluent-arch.svg" alt=""/>
   <br/>
   <i>The base architecture of Fluent</i>
</p>

The Fluent operates on a modified version of [Reth](https://github.com/fluentlabs-xyz/fluent),
using its own execution engine that replaces [Revm](https://github.com/fluentlabs-xyz/revm-rwasm).
It maintains backward compatibility with most existing Ethereum standards, such as transaction and block structures.
However, Fluent is not confined to Reth exclusively, as it features an independent execution runtime.

Furthermore,
Fluent enables a fork-less runtime upgrade model
by incorporating the most critical and upgradable runtime execution codebase within the genesis state.
The only persistent element within the runtime is the transaction format.

Additionally, Fluent is always post-Cancun compatible and does not support any EIPs implemented before the Cancun fork.
Maintaining backward compatibility with all previous forks is unnecessary.
The EVM runtime can be upgraded to retain compatibility with EVM.

[//]: # (## Blended Execution)

[//]: # ()
[//]: # (The core of Fluent is founded on Blended Execution.)

[//]: # (Blended execution enables native-level support for multiple VMs and EEs within a unified state machine.)

[//]: # (This enables real-time composability between contracts)

[//]: # (written in various programming languages originally built for different environments.)

[//]: # (On Fluent, this concept is employed to create an IR for executable applications.)

[//]: # ()
[//]: # (### Blended VM)

[//]: # ()
[//]: # (rWasm is a binary IR designed for computations.)

[//]: # (Wasm is converted into rWasm,)

[//]: # (where the majority of operations and segments are represented in a simplified and more zk-friendly format.)

[//]: # ()
[//]: # (rWasm is used to represent the execution trace of all operations within Fluent.)

[//]: # (To achieve this, as much as possible is compiled  into the rWasm IR,)

[//]: # (ensuring that every operation can be consistently represented using the same trace language.)

[//]: # (Additionally, rWasm zkVM circuits verify all state transitions.)

[//]: # ()
[//]: # (The main approach to enable blended execution on Fluent is to use only one all encompassing  VM under the hood,)

[//]: # (which is rWasm.)

[//]: # (In contrast to multi-VM implementations,)

[//]: # (having only one VM inside the state transition makes proving much faster and easier.)

[//]: # (In this case,)

[//]: # (compatibility with other EEs/VMs on Fluent is achieved through special AOT)

[//]: # (&#40;Ahead-of-Time&#41; compilers or simulation contracts.)