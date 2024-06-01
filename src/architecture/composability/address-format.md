# Address format

One of the biggest challenges is address format, since it's used to compute paths inside the tree it makes interoperability between different EEs almost impossible w/o any additional pre-compiled contracts and adapters.

|  Chain | Address format                     | Curve | Size |
| ------ |------------------------------------| ----- | ---- |
| EVM    | keccak256(uncompressed(G^x)[1:])[12..] | secp256k1 | 160 bits |
| SVM    | G^sha512(x)[..32]                  | ed25519 | 256 bits |
| FVM    | sha256(uncompressed(G^x))          | secp256k1 | 256 bits |

Table 1. different blockchains use different address schemes and elliptic curves

Mapping for addresses is not a solution, because there is no way we can easily prove mapping since they’re based on different curves and SOL uses hashed private keys instead, which can bring additional challenges and might require developing our version of ETH and SOL wallets that is unlikely. 

Our account/state system is based on JZKT (Journaled ZK Trie), that is Scroll-based SMBT (Sparse Merkle Binary Trie) on Poseidon hashing function. It uses 254 bit EC points to calculate path inside trie by doing poseidon hashing over address. Let’s check how trie key is calculated for ETH and SOL blockchains.

- For EVM address it pads to 20 bytes with zeros to achieve 32 byte size and then split into two elements to calculate binary path 
- For SVM it calculates path using 32 byte address that is greater than EVM’s 20 address 

As we can see, such a function can’t work for ETH and SOL addresses simultaneously and SOL and ETH live in different trie “spaces”, because of padded 20 bytes and can’t intersect anyhow. The same happens to FVM address format and all the rest remaining, like Polkadot, that uses ristretto curve. By default it makes it impossible to have any time of native interoperability w/o modifying blockchains address formats and cryptography.

## Solution

The solution is to use a new path function that can make binary representation of addresses in two chains inversely computable. By doing this we can calculate the binary path from one chain in another and vise-versa. The only way to determine such a function is to take the “worst” (that uses smallest address field) address format and align tire calculation to this address. We must take the smallest one because otherwise we can lose interoperability with this smallest address format. Today the smallest address is a 20 byte format that is used by Bitcoin (ripmd function) and Ethereum (keccak256 cut).

`path(addr)=G1lpad32(addr)[12..]`

Using this new path function we can do address translation from most of the chains to do cross account transfers even with different elliptic curves and hashing. Such a function can be calculated on-chain using WASM. 

Let's assume a SOL user wants to transfer some native tokens to an ETH user. He takes the user's ETH address and calculates SOL address by keeping the same binary structure. It can be achieved using the following formula.

`dest=base58(lpad32(hex_decode(address)))`

These two addresses have the same binary structure and affect the same leaves inside account trie. Transfer from ETH to SOL can be achieved by doing backward operations. 

## Problems

There are several potential problems that can happen with such model:

- Theoretically a blockchain with smaller address format can exist then it will make impossible to support interoperability with that blockchain in a native way (only though special pre-compiled contracts or address mappings). This is not the biggest problem because 20 bytes is the smallest that exists today and having less address size can cause security problems for such blockchain. 
- Users might be able to “lock” his funds in one binary representation. For example, user A has an address in ETH and user B in SOL. User A sends ERC20 tokens to user B Ethereum address that is mapped from Solana address. If such a thing happens then user B won’t be able to spend his ERC20 tokens because ERC20 exists in EVM space and there is no toolset for creating such transactions. It might happen if users are not aware of how the transfer model works, but it doesn’t lock funds forever. To protect against this issue developers must check accounts before transferring assets on the UI and provide a special UI for users where they can recover “locked” assets by creating and signing transactions in SOL or ETH using different ABI formats. 
