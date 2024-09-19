# Token Transfer

> **WARNING:** This section may be outdated!

There are several solutions to the problem of token transfer between different blockchain environments:

1. **Wrapped Token Projection**:
    - Create a wrapped token projection for both ERC20 and SPL tokens.
    - Use interoperability hooks to handle all ERC20/SPL events and trigger corresponding events in the appropriate EVM/SVM environment to simulate the same behavior.
    - **Drawbacks**:
        - This approach requires supporting Cartesian products for all VMs, which increases development and support complexity.
        - It reduces flexibility, and there is no guarantee that there are no non-simulatable features in one of these environments.

2. **Automatic Wrapped Tokens with Helper Functions**:
    - Create automatic wrapped tokens for ERC20 and SPL with helper functions such as `wrap`, `unwrap`, `wrapAndCall`, and `wrapAndCallAndUnwrap`.
    - These functions help users interact with contracts in both Ethereum (ETH) and Solana (SOL) systems.
    - **Benefits**:
        - Users can transfer their funds between SPL and ERC20 standards.
        - Enables interaction with both contract systems, simplifying the process for users.