# Execution Environment

Fluent EE is designed to be universal since it's targeted to support different VMs (virtual machines) and EEs (execution environments).
It's achieved by having rWASM virtual machine used to execute and simulate different EE inside.
Using this approach Fluent translates all applications into one execution language and adapts all these EEs to use the same state trie.
By having the same state, trie applications can do interoperability with each other.

The core of Fluent is a state trie.
Fluent supports its own EE, but also emulates other EEs like EVM or SVM.
Its achieved using Compatibility Contracts (CC) that is used to simulate functions that are required by other VMs.
There are a lot of challenges in sharing the same account trie between different EE, we solve it using CC.

For example, EVM,
SVM and other EEs have a balance instruction that returns a balance representation according to their specs.
It varies based on endianness, arithmetic size and many other parameters.
To solve this, every CC provides a function for fetching balance and maps it into EEs balance format
(like 256-bit BE format in EVM).