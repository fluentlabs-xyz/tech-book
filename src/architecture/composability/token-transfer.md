# Token transfer

There are several solutions of this problem:

- Create a wrapped token projection of both ERC20/SPL. We can do interop hooks to handle all ERC20/SPL events and trigger corresponding events in a right EVM/SVM env to simulate the same behavior. The biggest negative factor is that we need to support cartesian products for all VMs we have that increases development and support complexity and removes flexibility, plus there is no guarantee that there are no non-simulatable features in one of these environments.
- Create an automatic wrapped token for ERC20 and SPL with helper functions like `wrap`, `unwrap`, `wrapAndCall`, `wrapAndCallAndUnwrap` to help users easily interact with contracts in ETH and SOL systems. In this case users can transfer their funds from SPL to ERC20 standard and vice versa and interact with both contract systems.
