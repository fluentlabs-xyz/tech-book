# Composability

Fluent L2 is fundamentally a state tree that manages account information and execution runtimes.
Given the single account representation, this structure must be compatible with all supported VMs.
Various Execution Environments (EEs) such as EVM, SVM, and others have distinct account and storage formats.
To accommodate these differences, we employ diverse EE development strategies.

Fluent is an L2 blockchain that supports the Web3 API, is fully compatible with EVM smart contracts,
and allows developers to deploy both WASM and EVM apps simultaneously.
Technically, we don’t support EVM contracts directly,
but practically we do because, being WASM-based,
it is sufficient to support only one VM and simulate the other using any high-level language like Rust,
which can be compiled to WASM.

To achieve EVM compatibility, we use a special EVM runtime precompile that is responsible for running EVM bytecode.

## Challenges

Execution environments differ not only in transaction and block structures but also in cryptography and address formats.
This variability presents a significant challenge for Compatibility Contracts because:

- Different EEs compute paths inside the trie differently.
- Each EE has a unique storage layout.
- Bytecode storage and execution methods vary across chains.

By using Compatibility Contracts,
Fluent L2 ensures that these diverse environments can function cohesively within a unified state tree,
overcoming the inherent differences in structure and cryptography.

## Solution

The solution depends on the chosen EE integration strategy. Fluent offers two strategies for EE integration:

1. **Fully Compatible & Isolated EE**
2. **Partially Compatible & Interoperable EE**

### Fully Compatible & Isolated EE

By using this strategy,
Execution Environments (EEs) maintain an original address format but lack native interoperability between different EEs.
To manage deposits and withdrawals, a special runtime contract must be utilized.
This necessitates that funds be deposited into the EE via designated functions.

We define basic Solidity-ABI compatible interfaces to facilitate interaction with isolated EEs:

```solidity
interface IAmFullyCompatibleButIsolatedEE {
    // Deposits ETH into the EE
    function depositETH(bytes32 address) external;
    
    // Deposits an ERC20 token into the EE
    function depositERC20(bytes32 address, IERC20 token) external;
    
    // Withdraws ETH from the EE
    function withdrawETH(bytes params) external;
    
    // Withdraws an ERC20 token from the EE
    function withdrawERC20(bytes params, IERC20 token) external;
}
```

*Note: Method signatures are not fully finalized and may change in the future.*

> Implementing contracts are expected to support `Multicall`,
> which allows developers to combine deposit and withdrawal operations into a chain of actions.

### Advantages:
- **High Compatibility:** Fully or almost fully compatible with the original EE.
- **Seamless Integration:** Utilizes compatible addresses and cryptography, maintains the same transaction format, enabling the use of original tools, wallets, and explorers.
- **Cost-Effective Development:** Low development costs if the EE is `no_std` ready and can be compiled into WASM.
- **RPC Support:** Achieve full RPC support through a special RPC bridge or adapter.

### Disadvantages:
- **Gas Management Challenges:** Achieving full compatibility is hard due to gas management limitations, though partial compatibility is possible via account emulation.
- **Interoperability Issues:** Emulated accounts cannot directly interact with external contracts, requiring withdrawals. Despite the instant withdrawal process that can be executed through multicall, it increases the execution cost.
- **Emulation Overhead:** Certain functions introduce computation overhead due to discrepancies in state models or account and transaction structures. Running a VM inside VM can cause performance losses.