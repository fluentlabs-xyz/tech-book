# Isolated EE

Achieving full EE compatibility with the original VM involves running an entire EE runtime as a smart contract.
While this is the most straightforward approach to ensure compatibility with the original EE,
it presents various challenges for integration and composability with other EEs on Fluent.
These challenges can affect the management of storage, address formats, and gas calculations.

<p align="center">
   <img src="../../images/isolated-ee.svg" alt=""/>
   <br/>
   <i>Architecture design of Isolated EE with an RPC adapter</i>
</p>

To integrate an EE on Fluent using the isolated approach requires a Wasm-based smart contract with an entry point.
This entry point takes a raw transaction as input, parses it, and then executes it.

```rust
fn main() {
    // get raw input transaction for your EE, parse and verify transaction
    let parsed_tx = parse_and_verify_tx_from_input();
    // execute transaction
    let exec_result = exec_tx(parsed_tx);
    // forward all required info if needed (like logs, output and exit codes)
}
```
*Note: This snippet is pseudocode. For more detailed development guides, please refer to the [Fluent Docs](https://docs.fluentlabs.xyz/).*

The biggest advantage of such an approach is that it can support custom transactions,
signature verification mechanisms and even address formats.
It works for EEs like the Solana and FuelVM.

Advantages:
- **High Compatibility**: Full or almost full compatibility with the original EE.
- **Seamless Integrations**: Utilizes compatible addresses and cryptography, maintains the same transaction format, enables the use of original tools, wallets, and explorers. Achieve full RPC support through a special RPC bridge or adapter.
- **Cost-Effective Development**: Low development costs if the EE is no_std ready and can be compiled into Wasm.

Disadvantages:
- **Gas Management**: Ensuring full compatibility poses a challenge due to gas management limitations. The gas measurement approach in Fluent EE often diverges from that in Isolated EE, making it generally impractical to align the two policies.
- **Interoperability Issues**: Accounts in an isolated EE are emulated and cannot directly interact with contracts using the blended EE model (described below), requiring withdrawals. Despite an instant withdrawal process that can be executed through multicall, it increases execution costs and decreases user experience by needing to interact with separate wallets and token standards across isolated EEs.
- **Emulation Overhead**: Certain functions introduce computation overhead due to discrepancies in state models or account and transaction structures. Running a VM inside a VM can cause performance losses.

## Composability

By using this method, Isolated EEs maintain an original address format but lack native interoperability between the different EEs available on Fluent.
To manage deposits and withdrawals from the EE, a special runtime contract must be utilized.
This necessitates that funds be deposited into the EE via designated functions.

Fluent defines basic Solidity-ABI compatible interfaces to facilitate interaction with such EEs:

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

    // Get non-claimed relayer fee    
    function getRelayerFee(address relayer) external view returns (u256);
    
    // Claim unclaimed relayer fee
    function claimRelayerFee() external;
}
```

*Note: Method signatures are not fully finalized and may change in the future.*

> Contracts are expected to support `Multicall`, which allows developers to combine deposit and withdrawal operations into a chain of actions.