# Account Trie

The account structure in rWASM is designed to be as simple as possible, containing only the most essential fields.
It's fully compatible with an original Ethereum account structure.

```rust
pub struct Account {
    pub address: Address,
    pub balance: U256,
    pub nonce: u64,
    pub code_hash: B256,
    pub code_size: u64,
}
```

Fields description:
- **`address`**: This transient field holds the account address. Currently, a 20-byte address is used to ensure compatibility with the EVM account structure. However, there is a possibility of extending this to 32 bytes in the future to align with the state trie account path, thereby enhancing interoperability.
- **`balance`**: Represents the account balance as a 256-bit element. This is consistently expressed as a 256-bit Big Endian value, although future changes may be considered.
- **`nonce`**: Indicates the number of transactions initiated by this account. It increments with each transaction, call, or contract creation, regardless of the operation's success.
- **`code_hash`**: A Poseidon hash representing the translated bytecode in rWASM format.
- **`code_size`**: Denotes the size of the compiled bytecode in rWASM IR binary format. This bytecode has successfully passed all static validations and is optimized for ZK proofs.

## State Trie

The trie structure uses SMBT (Sparse Merkle Binary Trie),
a fork of ZkTrie originally developed
and maintained by [Scroll](https://docs.scroll.io/en/technology/sequencer/zktrie/).

*Note: Considering replacing the trie hashing function with a more efficient alternative.*

Fluent operates with state tries through a pure functional approach,
where every smart contract and root-STF can be represented as a function.
In this model, the input provides a list of dependencies,
and the output yields an execution result along with a number of logs.

However, this isn't entirely feasible due to cold storage reads and external storage dependencies,
such as CODEHASH-like EVM opcodes.
To address this, Fluent employs an interruption system to "request" missing information from the root-STF.
This is particularly useful for operations involving cold storage or invalidated warm storage.

The same concept is also used to handle nested calls without incurring additional simulation overhead.

## Account Destruction Problem

The Ethereum Virtual Machine (EVM)
utilizes dirty storage and journals to roll back changes and revert to previous states.
One of the main challenges is handling the `SELFDESTRUCT` opcode, which is responsible for account destruction.

Account destruction can introduce several edge cases.
When an account is destructed, all state changes, including storage modifications,
must be reverted, irrespective of the destruction stage.

In the post-CANCUN era, Fluent has no need to remove existing storage tries.
Account destruction in Fluent can be accomplished
by sending a special interruption message into the root-STF with a specified command.
Since Fluent-STF is a pure function, it can implement account destruction through journal reversion.  