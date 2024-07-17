# State Transition Function

**State Transition Function (STF)** defines the transition from state `t` to state `t+1`.
This function usually takes two states and a dependent state to calculate or verify the transition.

States can describe various aspects, including block state transitions, precompile state transitions,
or even user-application-specific state transitions.

Let's examine several state transition functions:

- **Block State Transition**: Verifies the correctness of block state transitions, ensuring that `block'` correctly follows `block`.
- **Executor State Transition**: Executes a raw transaction and calculates the output state.
- **User-specific State Transition**: Developed by end-users, these functions affect account balances, states, and storage.

A generalized state transition function, often referred to as **STF**,
is used to calculate state transitions for all these different STFs.
STF is crucial for ZK proofs, as it proves the correctness of block and state transitions,
including state calculation and instruction set transitions.
For example, calculating the sum of two elements using WebAssembly's `i32.add` instruction is a state transition,
affecting the stack's top elements and modifying the stack pointer (SP) register.

## Missing state

The main challenge of state transition is that it requires knowledge of both previous and current states.
This task can be complex, especially when calculating user-specific state transitions.
For instance, a user signs a transaction and calculates an access list with affected accounts and storage elements.
Since storage is shared, the user might not know the correct storage slot numbers or even account addresses,
as these can depend on previous block calculations.

Ethereum addresses this issue using cold/warm state trie slots. However, this solution is not perfect,
as pre-calculated access lists cannot be modified after being signed by the user.

There are three potential solutions to this problem:

1. **Mandatory Access Lists**: In Ethereum, access lists are non-mandatory, and there is a penalty for cold slot reads. To address this, we could prohibit all state misses and revert such transactions. However, this might significantly affect user experience.
2. **Interactive Transaction Pool**: This involves block inclusion commitments with a semi-interactive access list recalculation protocol. Transactions are included in the upcoming block, and users wait for inclusion. An interactive protocol updates access lists. This solution would require patching all Web3 eth-compatible browser extensions to support re-signing, which is unlikely.
3. **Execution Interruption**: Interrupting the state transition execution to reload it with the correct execution state. This requires a resumable VM, like rWASM VM. However, state reload is a costly task in terms of execution and can impact overall block execution performance.