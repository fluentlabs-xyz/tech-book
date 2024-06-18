# Composability

At the lowest level, Fluent L2 is a state tree that stores information about accounts and an execution runtime. Since only one account representation exists, the account structure must be adapted to all supported VMs. All EE account structures might be different; to solve this problem, so-called Compatibility Contracts are used. These contracts are required to simulate different environments, including EVM, SVM, etc.

For example, EVM has instructions to interact with storage that are used to store information about modified cells inside the sub-trie of each account. Nested tries are not supported, so EVM’s storage layout needs to be mapped to the storage layout. The same can happen with obtaining context-specific information, including block or transaction details, like coinbase or transaction signer.

All execution environments (EVM, SVM, etc.) use not only different transaction and block structures but also different cryptography and address formats. This brings the biggest challenge to the Compatibility Contracts model because these EEs use different ways to compute paths inside the trie. This means that all these chains have different storage layouts and different ways to store and execute bytecode.
