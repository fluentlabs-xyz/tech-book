# Execution Environment

Fluent EE is designed to be universal, supporting various virtual machines (VMs) and execution environments (EEs).
This universality is achieved through the rWASM virtual machine, which executes and simulates different EEs.
By using rWASM, Fluent translates all applications into a single execution language,
enabling different EEs to share the same state trie.
This shared state trie facilitates seamless interoperability among applications.

### Core Structure

The core of Fluent is a state trie.
Fluent supports its own EE and emulates other EEs,
such as the Ethereum Virtual Machine (EVM) and the Solana Virtual Machine
(SVM).
This emulation is achieved using Compatibility Contracts (CCs), which simulate the functions required by other VMs.
Sharing the same account trie among different EEs poses significant challenges,
but Fluent overcomes these by leveraging CCs.

### Compatibility Contracts

Different EEs have unique requirements for balance instructions,
including variations in endianness, arithmetic size, and other parameters.
Compatibility Contracts address these differences
by providing functions that fetch balances and map them into the appropriate format for each EE.
For example, the EVM requires a 256-bit big-endian format, which the corresponding CC ensures is provided.

### Emulation Examples

- **EVM**: Uses Compatibility Contracts to simulate EVM functions, translating them into rWASM instructions that interact with the shared state trie.
- **SVM**: Similar to EVM, SVM functions are simulated via Compatibility Contracts, ensuring that the specific needs of the SVM are met within the shared state structure.

By using Compatibility Contracts, Fluent EE maintains a universal and interoperable environment, allowing different execution environments to function cohesively within a single, unified state trie.