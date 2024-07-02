# Compatibility Contracts

Fluent is an L2 blockchain that supports the Web3 API, is fully compatible with EVM smart contracts, and allows developers to deploy both WASM and EVM apps simultaneously. Technically, we don’t support EVM contracts directly, but practically we do because, being WASM-based, it is sufficient to support only one VM and simulate the other using any high-level language like Rust, which can be compiled to WASM.

To achieve EVM compatibility, we use so-called Compatibility Layers. A Compatibility Layer (CL) is a special smart contract developed using a WASM language. The difference between CL contracts and regular smart contracts is that the former has access to special low-level functions that can be used to manage balances, bytecodes, and the account trie.

## Current Compatibility Layers

### ECL (EVM Compatibility Layer)

- **Purpose**: Brings compatibility with EVM instructions by providing special WASM functions that have 100% compatible behavior with EVM instructions.
- **Example**: The EVM instruction `COINBASE` provides access to the block’s coinbase. ECL provides similar functionality through the `_evm_coinbase` function.
- **EVM Calls**: Developers can run EVM bytecode using ECL's compatible call/create function families. These functions inject the EVM runtime and execute bytecode as is. Although this can add overhead to execution and proving, we are working on optimizations.

### WCL (WASM Compatibility Layer)

- **Purpose**: Provides functions to deploy and run WASM contracts.
- **Functionality**: The deploy function translates WASM bytecode into rWASM, and the call function executes rWASM bytecode. This allows developers to deploy and run WASM applications.

### Future Compatibility Layers

Any CL can be implemented to support additional binary formats like ELF+RISC-V (used in RiscZero), MoveVM, or Solana binaries. The method for routing the deployer to the correct CL during deployment or function call has not been finalized. Currently, this is solved by checking binary signatures to choose the right CL, though this approach may not be optimal due to potential EVM collisions and safety concerns.

## Functions for Interacting with Runtimes

The following contracts and functions are utilized to interact with EVM and WASM runtimes, including the deployment and invocation processes:

- `_evm_create`
- `_evm_call`
- `_wasm_create`
- `_wasm_call`

## Encoding and Decoding Parameters

Solidity apps use a special ABI encoding format that is inefficient for use in WASM apps. We do not solve this problem directly and leave it to the developers. Developers must be aware of how the app is developed and deployed. They already manage this for Solidity interoperability, as it is impossible to encode input parameters without knowing the smart contract specification.

### Interoperability Scenarios

- **EVM -> EVM**: EVM apps are designed to interact with other EVM apps using the same ABI encoding standards. We can safely replace any EVM to EVM calls with our `_evm_call` function.
- **EVM -> non-EVM**: Developers must encode input parameters based on the smart contract’s ABI standards and execute the appropriate CL contract (e.g., WCL). For example, an EVM developer encoding two numbers for a WASM contract would use the WASM ABI encoding format and call WCL with the required parameters.
- **non-EVM -> EVM**: WASM apps can easily encode any ABI standards and interact with any CL contracts natively. Developers use Solidity ABI encoding for EVM contracts and WASM ABI encoding for WASM contracts.
- **non-EVM -> non-EVM**: WASM can natively use any encoding/decoding format to interact with any type of app.

## WASM ABI: Codec

The WASM ABI, called Codec, implements similar ideas to the Solidity ABI but consumes less memory. This library is being redesigned to be more compatible with the Solidity ABI and more friendly for Solidity ABI encodings. Using the Solidity ABI for WASM apps is also being considered, but the decision depends on benchmarks.