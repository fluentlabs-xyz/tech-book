# Account Trie

### Account

We're trying to keep the account structure as simple as possible.
It contains only the most important fields; all the rest must be supported by CC.

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

Where:
- `address` - a transient field that stores the account address. We use a 20-byte account address length to be compatible with the EVM account structure, but we might change it in the future to a 32-byte size to match the state trie account path and to simplify interoperability.
- `balance` - a 256-bit element that represents the account balance. We always represent the balance as a 256-bit BE value, but it can be changed in the future.
- `nonce` - the number of calls made by this account. It increments once a new transaction, call, or create operation is executed, regardless of its success.
- `source_code_size` - the size of the original bytecode used to create an account. We must store this information to support opcodes like `CODESIZE`, `CODECOPY`, `EXTCODESIZE`, and `EXTCODECOPY`, but storing this information is not fully necessary.
- `source_code_hash` - a Keccak256 hash of the source bytecode, which is also required to support `CODEHASH` and `EXTCODEHASH` instructions.
- `rwasm_code_size` - the size of the translated version of the source bytecode in rWASM IR binary format that has already passed all static validations and is more ZK-friendly.
- `rwasm_code_hash` - a Poseidon hash of the translated bytecode in rWASM.

### Trie

For the trie structure, SMBT (Sparse Merkle Binary Trie) is used, which is a fork of ZkTrie originally developed and maintained by [Scroll](https://docs.scroll.io/en/technology/sequencer/zktrie/).

Every account operation technically modifies an account trie, but since transactions or nested calls can be reverted, the trie cannot be modified until it is fully confirmed that the operation is non-revertible. Journals are the easiest way to achieve this.

Fluent uses a simplified version of journals with its own wrapper over SMBT that enables journaling for every trie operation. Instead of managing all journals inside memory, trie operations are marked with an additional flag. This flag is used to mark leaves that are not involved in the final state root computation. Using this approach, by adding only one additional column to the account trie gadget, the number of memory and stack operations, which are much more expensive, can be significantly reduced.




These are all the operations that our trie supports:
- `checkpoint` - creates a new checkpoint state that is a position inside the journal. Once a checkpoint is created, the developer can roll back some changes to this checkpoint state.
- `get` - reads a committed or non-committed leaf state from the trie. By passing the `is_committed` flag, you can retrieve leaf info from the committed or non-committed state.
- `update` - writes a new non-committed leaf state in the trie (dirty state). This function always modifies the non-committed state. To commit all dirty changes, the `commit` function must be used.
- `remove` - removes a leaf from the trie (planning to remove).
- `compute_root` - computes a state root based on committed data.
- `emit_log` - emits a new log (like the EVM log instruction). We must support this log function here inside our trie because it also affects potential rollback operations.
- `commit` - commits all dirty changes and applies them to the final state root.
- `rollback` - rolls back changes to the provided checkpoint.
- `update_preimage` - updates or inserts a preimage for one of the hashes used inside a leaf (non-indexed data). We have a special database where we store information about non-indexed data or preimages for hashes. For example, inside a leaf, we only store the bytecode hash, but the original bytecode is stored inside the preimage database.
- `preimage_size` - gets the size of an existing preimage. This function can be used for instructions like `CODESIZE` or `EXTCODESIZE` to retrieve the size of a preimage based on the hash provided.
- `preimage_copy` - copies an existing preimage into memory.

#### Account destruction problem

The biggest problem with journals in EVM is handling nested calls and supported account destruction.
EVM uses dirty storage and journals to roll back all changes and revert to the previous state.
The biggest challenge here is the `SELFDESTRUCT` opcode or account destruction.
There are many corner cases that can occur during account destruction.
Once an account is destructed (no matter at what stage it exists), all state changes must be reverted, including storage.

Since EVM uses nested Merkle tries to represent storage for each contract, we can't store all journal logs inside a flat, single-dimensional list because, in EVM, you can roll back one of the nested calls.
We solve this by splitting the account trie and storage trie into two separate structures.
We can do this because Fluent is strictly post-CANCUN, and there is no state removal for existing accounts.
There is still an issue with newly created accounts, but we're working on a solution.
