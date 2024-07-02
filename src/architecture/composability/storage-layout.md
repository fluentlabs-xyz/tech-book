# Storage layout

We have two types of storage:
1. Account trie storage—for account info including code hashes, balances, nonce, etc. 
2. Contract storage—random storage key/value storage inside account trie.
3. Preimage storage—an external storage with preimages for hashes that are inside account/storage.

Ethereum stores storage inside account's sub-trie,
we don't do this for simplicity of the design
and since we post-Cancun then we don't care about account destruction, and it's not a strict requirement for us.
Also, Ethereum's storage design brings some challenges
if we decide to support other storage layouts where storage collisions can happen.
For example, Solana malicious app can modify ERC20 balances.
To solve this, we use different storage key calculation functions for different EEs.

For EVM we use the following formula: `storage_key = poseidon(poseidon(slot_0, slot_1), address)`

SVM storage layout is significantly different, and it uses 10kB chunks instead of storage slots.
Each transaction can increase chunk size not greater than 10kB.
We store only hashes of these chunks instead of data itself inside trie, that is much more compact.
We use the following formula: `storage_key = address + chunk_index`

To make sure there are no collisions between EVM and SVM, we assign a special 1-byte identifier to each EE
and replace the first byte of the storage key with this identifier. 

| Chain    | Storage prefix |
|----------|----------------|
| EVM      | 0x45 ('E')     |
| SolanaVM | 0x53 ('S')     |
| FuelVM   | 0x46 ('F')     |
| MoveVM   | 0x4d ('M')     |
