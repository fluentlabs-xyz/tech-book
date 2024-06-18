# Execution Environment

Fluent EE is designed to be universal, targeting support for various virtual machines (VMs) and execution environments (EEs). This universality is achieved through the rWASM virtual machine, which executes and simulates different EEs. By utilizing rWASM, Fluent translates all applications into a single execution language, allowing different EEs to share the same state trie. This shared state trie enables applications to interoperate seamlessly.

The core of Fluent is a state trie. Fluent not only supports its own EE but also emulates other EEs such as the Ethereum Virtual Machine (EVM) and the Solana Virtual Machine (SVM). This emulation is accomplished using Compatibility Contracts (CC), which simulate the functions required by other VMs. Sharing the same account trie among different EEs poses significant challenges, but Fluent overcomes these by leveraging CCs.

For instance, EVM, SVM, and other EEs have balance instructions that return a balance representation according to their specific requirements. These requirements vary based on factors like endianness, arithmetic size, and other parameters. To address this, each CC provides a function to fetch the balance and map it into the appropriate format for the respective EE, such as the 256-bit big-endian format used in EVM.
