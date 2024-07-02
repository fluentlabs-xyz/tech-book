# Address Format

One of the biggest challenges is the address format, as it is used to compute paths inside the tree,
making interoperability between different EEs almost impossible without additional pre-compiled contracts and adapters.

| Chain | Address Format                           | Curve     | Size     |
|-------|------------------------------------------|-----------|----------|
| EVM   | `keccak256(uncompressed(G^x)[1:])[12..]` | secp256k1 | 160 bits |
| SVM   | `G^SHA512(x)[..32]`                      | ed25519   | 256 bits |
| FVM   | `SHA256(uncompressed(G^x))`              | secp256k1 | 256 bits |

*Table 1. Different blockchains use different address schemes and elliptic curves.*

Mapping addresses is not a viable solution,
as there is no straightforward way to prove the mapping due to different curves and Solana's use of hashed private keys.
This would introduce additional challenges and might require developing our versions of ETH and SOL wallets,
which is unlikely.

Our account/state system is based on JZKT (Journaled ZK Trie),
a Scroll-based SMBT (Sparse Merkle Binary Trie) using the Poseidon hashing function.
It uses 254-bit EC points to calculate paths inside the trie by hashing the address with Poseidon.
Let’s examine how trie keys are calculated for ETH and SOL blockchains:

- For an EVM address, it pads to 20 bytes with zeros to achieve a 32-byte size, then splits into two elements to calculate the binary path.
- For an SVM address, it calculates the path using a 32-byte address, which is longer than the EVM’s 20-byte address.

As seen, this function can't work simultaneously for ETH and SOL addresses,
as they occupy different trie "spaces" due to the 20-byte padding, preventing intersection.
The same issue applies to the FVM address format and others, like Polkadot, which uses the Ristretto curve.
This default setup makes native interoperability impossible without modifying blockchain address formats and cryptography.

## Solution

The solution is
to use a new path function that makes binary representation of addresses in two chains inversely computable.
This allows us to calculate the binary path from one chain to another and vice versa.
The key is to use the smallest address format to ensure compatibility.
The smallest address format today is the 20-byte format used by Bitcoin (RIPEMD-160) and Ethereum (keccak256 cut).

```
path(addr) = G1lpad32(addr)[12..]
```

Using this new path function, we can achieve address translation across most chains for cross-account transfers, even with different elliptic curves and hashing. This function can be calculated on-chain using WASM.

For example, if a SOL user wants to transfer native tokens to an ETH user,
they can take the ETH address and calculate the SOL address while maintaining the same binary structure.
This can be achieved using the following formula:

```
dest = base58(lpad32(hex_decode(address)))
```

These two addresses have the same binary structure and affect the same leaves inside the account trie.
Transfers from ETH to SOL can be achieved by performing the reverse operations.

## Problems

Several potential problems may arise with this model:

1. **Smaller Address Formats**: If a blockchain with a smaller address format than 20 bytes emerges, native interoperability would be impossible without special pre-compiled contracts or address mappings. However, this is not a major issue, as 20 bytes is the smallest address size currently in use, and smaller sizes could pose security risks for such a blockchain.

2. **Locked Funds**: Users might inadvertently "lock" their funds in one binary representation. For instance, if user A (ETH) sends ERC20 tokens to user B's Ethereum address (mapped from Solana), user B may not be able to spend those tokens due to the lack of a transaction toolset in EVM space. To prevent this, developers must check accounts before asset transfers in the UI and provide a special interface for users to recover "locked" assets by creating and signing transactions in SOL or ETH using different ABI formats.