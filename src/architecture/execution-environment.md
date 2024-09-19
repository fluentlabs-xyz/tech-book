# Execution Environment

Fluent EE is designed to be universal, supporting various virtual machines (VMs) and execution environments (EEs).
This universality is achieved through the rWASM virtual machine, which executes and simulates different EEs.
By using rWASM, Fluent translates all applications into a single execution language,
enabling different EEs to share the same state trie.
This shared state trie facilitates seamless interoperability among applications.

Fluent EE achieving support for different Execution Environments (EE) can vary significantly based on numerous factors.
These factors include the type of cryptography used (particularly when a raw transaction is processed),
the percentage of compatible features, and the address format.

There are three potential approaches to building an EE within Fluent L2:
- Full EE simulation for complete compatibility
- Native cross-contract calls with EVM/WASM for full interoperability

Given that each EE/VM can introduce unique execution standards,
various integration challenges may arise.
Let's explore the most significant ones.

## Isolated (Fully Compatible) EE

Achieving full EE compatibility involves running the entire EE runtime as a smart contract.
While this is the most straightforward approach to ensure compatibility, it presents various challenges for integrators.
These challenges can affect the management of storage, address formats, and gas calculations.
Fortunately, most of these issues are solvable, and we have highlighted the primary concerns above.

To integrate, an EE developer should create a WASM-based smart contract with an entry point.
This entry point takes a raw transaction as input, parses it, and then executes it.

```rust
fn main() {
    // get raw input transaction for your EE, parse and verify transaction
    let parsed_tx = parse_and_verify_tx_from_input();
    // execute transaction
    let exec_result = exec_tx(parsed_tx);
    // forward all required info if needed (like logs, output and exit codes)
}
```
*Note: This snippet is pseudocode. For more detailed development guides, please refer to the relevant sections.*

The biggest advantage of such an approach is that it can support custom transaction,
signature verification mechanism and even address format.
It works for EE(s) like SolanaVM, FuelVM, etc.

But for some EE(s) more native EE integration can be applied.

## Native Compatible EE

Native Compatible EE operates as an execution proxy.
Since **Fluent L2** only supports **rWASM** bytecode, developers have two main options:

1. Create WASM-based contracts that execute other bytecode.
2. Develop AOT compilers that translate their custom bytecode into **rWASM**.

**Fluent L2** incorporates EVM using this proxy model.
A special proxy with a delegate calls forwards execution to a unique EVM loader smart contract.
This setup eliminates the need for address mapping or transaction verification.

*Note: An Ahead-Of-Time (AOT) compiler for EVM to rWASM is currently a work in progress and will eventually replace the existing proxy model.*

**Advantages:**

- Developers can use any ABI encoding/decoding format.
- Applications can be managed using default EVM-compatible data structures, such as storage, block/transaction structures.

As a result, apps built with this model can natively interoperate with other native-compatible EEs. Since they share the same address space, isolation isn't required. Consequently, WASM apps can directly interact with EVM apps and vice versa.

## Problems and Solutions

1. **Incompatible Cryptography**: Execution Environments (EE) can consume an entire transaction as an input, requiring the use of system bindings to verify signature correctness. Fluent supports pre-compiles for a range of commonly used cryptographic functions (e.g., secp256k1, ed25519, bn254, bls384). For any missing cryptographic functions, you can implement them as custom precompiled contracts.

2. **Different Address Format**: Fluent uses an Ethereum-compatible 20-byte address format. If an address uses a different derivation format or has more bytes than a contract can store, there needs to be a way to handle this. Such addresses can be stored as so-called projected addresses, which are calculated using any hashing function. Account information can then be stored inside the storage mapping of the EE account.

3. **Varying Gas Calculation Policies**: EE/VM may use different gas calculation policies compared to Fluent L2. To address this, we introduce two distinct gas calculation policies:

   - *Standard Gas Calculation*: Applies to typical operations, assigning a specific gas cost to each rWASM opcode.
   - *Manual Gas Calculation*: Available exclusively for development purposes and for trusted pre-compiled smart contracts by Fluent.

   This approach ensures flexibility and maintains the integrity of operations across different environments.

4. **Custom Bytecode Storage**: There is a need to store immutable data like custom bytecode or some EE specific context information. Fluent provides a preimage database that can be used to store immutable data, including custom bytecode or other data.

5. **Variable Storage Size**: Some Execution Environments (EEs) implement variable storage key/value lengths. For instance, Solana uses 10kB chunks, while Cosmos utilizes variable key/value lengths with certain constraints. Storing these datasets within Ethereum's standard 32-byte storage format may lead to significant performance issues and increased gas consumption. To address this, Fluent offers an additional API that allows developers to use custom storage solutions for varying data lengths efficiently.
