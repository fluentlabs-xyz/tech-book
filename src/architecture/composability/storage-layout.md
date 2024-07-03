# Storage Layout

We have three types of storage:

1. **Account Trie Storage**: For account information, including code hashes, balances, nonces, etc.
2. **Contract Storage**: Random key/value storage inside the account trie.
3. **Preimage Storage**: An external storage containing preimages for hashes within the account/storage.

Ethereum stores storage inside the account's sub-trie.
We deviate from this for design simplicity and because, post-Cancun, we don't prioritize account destruction.
Moreover,
Ethereum's storage design introduces challenges
if supporting alternative storage layouts where storage collisions could occur
(e.g., a malicious Solana app modifying ERC20 balances).
To address this, we use different storage key calculation functions for different execution environments (EEs).

### EVM Storage

For the EVM, we use the following formula:
```
storage_key = poseidon(poseidon(slot_0, slot_1), address)
```

### SVM Storage

The SVM storage layout is significantly different.
It uses 10kB chunks instead of storage slots,
with each transaction able to increase the chunk size by no more than 10kB.
We store only the hashes of these chunks, rather than the data itself, within the trie for greater compactness.
The formula used is:
```
storage_key = address + chunk_index
```

### Collision Prevention

To prevent collisions between EVM and SVM,
we assign a unique 1-byte identifier to each EE and replace the first byte of the storage key with this identifier.

| Chain    | Storage Prefix |
|----------|----------------|
| EVM      | 0x45 ('E')     |
| SolanaVM | 0x53 ('S')     |
| FuelVM   | 0x46 ('F')     |
| MoveVM   | 0x4d ('M')     |