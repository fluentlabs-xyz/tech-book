# Composability

At the lowest level, Fluent L2 is a state tree that stores information about accounts and an execution runtime. Since we have only one account representation, we must adapt our account structure to all VMs we support. All EE account structures might be different; to solve this problem, we use so-called Compatibility Contracts. These contracts are required to simulate different environments, including EVM, SVM, etc.

For example, EVM has instructions to interact with storage that are used to store information about modified cells inside the sub-trie of each account. We don’t support nested tries, so we need to map EVM’s storage layout to our storage layout. The same can happen with obtaining context-specific information, including block or transaction details, like coinbase or transaction signer.

All execution environments (EVM, SVM, etc.) use not only different transaction and block structures but also different cryptography and address formats. This brings the biggest challenge to our Compatibility Contracts model because these EEs use different ways to compute paths inside the trie. This means that all these chains have different storage layouts and different ways to store and execute bytecode.
