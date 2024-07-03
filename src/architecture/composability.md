# Composability

At its core, Fluent L2 is a state tree that stores information about accounts and an execution runtime.
Since there is only one account representation, the account structure must be adapted to all supported VMs.
Different execution environments (EEs) like EVM, SVM, etc., have varying account structures.
To address this, we use Compatibility Contracts.
These contracts simulate different environments, ensuring seamless integration.

### Compatibility Contracts

For instance, EVM includes instructions to interact with storage,
storing information about modified cells within each account's sub-trie.
As nested tries are not supported, the EVM’s storage layout needs to be mapped to Fluent's storage layout.
This also applies to retrieving context-specific information,
such as block or transaction details like coinbase or transaction signer.

### Challenges

Execution environments differ not only in transaction and block structures but also in cryptography and address formats.
This variability presents a significant challenge for Compatibility Contracts because:

- Different EEs compute paths inside the trie differently.
- Each EE has a unique storage layout.
- Bytecode storage and execution methods vary across chains.

By using Compatibility Contracts,
Fluent L2 ensures that these diverse environments can function cohesively within a unified state tree,
overcoming the inherent differences in structure and cryptography.