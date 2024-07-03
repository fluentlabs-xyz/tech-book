# Account Trie

### Account

The account structure in rWASM is designed to be as simple as possible, containing only the most essential fields.
CC (Compatability Contract) must support all other functionalities.

```rust
pub struct Account {
    pub address: Address,
    pub balance: U256,
    pub nonce: u64,
    pub source_code_size: u64,
    pub source_code_hash: B256,
    pub rwasm_code_size: u64,
    pub rwasm_code_hash: F254,
}
```

- `address`: A transient field that stores the account address. We use a 20-byte account address to be compatible with the EVM account structure, but we might change it to 32 bytes in the future to match the state trie account path and simplify interoperability.
- `balance`: A 256-bit element representing the account balance, always represented as a 256-bit BE value, though this may change in the future.
- `nonce`: The number of calls made by this account. It increments with each new transaction, call, or create operation, regardless of success.
- `source_code_size`: The size of the original bytecode used to create an account. This information is necessary for opcodes like `CODESIZE`, `CODECOPY`, `EXTCODESIZE`, and `EXTCODECOPY`, but storing it is not strictly necessary.
- `source_code_hash`: A Keccak256 hash of the source bytecode, required for `CODEHASH` and `EXTCODEHASH` instructions.
- `rwasm_code_size`: The size of the translated version of the source bytecode in rWASM IR binary format, which has passed all static validations and is more ZK-friendly.
- `rwasm_code_hash`: A Poseidon hash of the translated bytecode in rWASM.

### Trie

The trie structure uses SMBT (Sparse Merkle Binary Trie),
a fork of ZkTrie originally developed
and maintained by [Scroll](https://docs.scroll.io/en/technology/sequencer/zktrie/).

Every account operation technically modifies an account trie.
However, because transactions or nested calls can be reverted,
the trie cannot be modified until it is confirmed that the operation is non-revertible.
Journals are the simplest way to achieve this.

Fluent uses a simplified version of journals with its own wrapper over SMBT
that enables journaling for every trie operation.
Instead of managing all journals in memory, trie operations are marked with an additional flag.
This flag marks leaves that are not involved in the final state root computation.
By adding just one additional column to the account trie gadget, the number of memory and stack operations,
which are much more expensive, can be significantly reduced.

The trie supports the following operations:

- `checkpoint`: Creates a new checkpoint state, a position inside the journal. Developers can roll back changes to this checkpoint state.
- `get`: Reads a committed or non-committed leaf state from the trie. By passing the `is_committed` flag, you can retrieve leaf info from the committed or non-committed state.
- `update`: Writes a new non-committed leaf state in the trie (dirty state). This function always modifies the non-committed state. To commit all dirty changes, use the `commit` function.
- `remove`: Removes a leaf from the trie (planning to remove).
- `compute_root`: Computes a state root based on committed data.
- `emit_log`: Emits a new log (similar to the EVM log instruction). This log function must be supported within the trie as it also affects potential rollback operations.
- `commit`: Commits all dirty changes and applies them to the final state root.
- `rollback`: Rolls back changes to the provided checkpoint.
- `update_preimage`: Updates or inserts a preimage for one of the hashes used inside a leaf (non-indexed data). A special database stores information about non-indexed data or preimages for hashes. For example, the leaf stores the bytecode hash, but the original bytecode is stored in the preimage database.
- `preimage_size`: Gets the size of an existing preimage. This function can be used for instructions like `CODESIZE` or `EXTCODESIZE` to retrieve the size of a preimage based on the provided hash.
- `preimage_copy`: Copies an existing preimage into memory.

#### Account Destruction Problem

The biggest challenge with journals in EVM is handling nested calls and supporting account destruction.
EVM uses dirty storage and journals to roll back all changes and revert to the previous state.
The biggest challenge is the `SELFDESTRUCT` opcode or account destruction.
Many corner cases can occur during account destruction.
Once an account is destructed (regardless of the stage), all state changes must be reverted, including storage.

EVM uses nested Merkle tries to represent storage for each contract.
Storing all journal logs in a flat,
single-dimensional list is not feasible because EVM allows rolling back one of the nested calls.
This issue is resolved by splitting the account trie and storage trie into two separate structures.
This approach is possible because Fluent is strictly post-CANCUN, with no state removal for existing accounts.
There is still an issue with newly created accounts, but a solution is being developed.