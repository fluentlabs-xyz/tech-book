# Compatability contracts

Fluent is an L2 blockchain that supports the Web3 API, is fully compatible with EVM smart contracts, and allows developers to deploy both WASM and EVM apps simultaneously. Technically, we don’t support EVM contracts directly, but practically we do because, being WASM-based, it is sufficient to support only one VM and simulate the other using any high-level language like Rust, which can be compiled to WASM.

To achieve EVM compatibility, we use so-called Compatibility Layers. A Compatibility Layer (CL) is a special smart contract developed using a WASM language. The difference between CL contracts and regular smart contracts is that the former has access to special low-level functions that can be used to manage balances, bytecodes, and the account trie.

Right now, we support two Compatibility Layers:
- ECL (EVM Compatibility Layer) - it brings compatibility with EVM instructions by providing special WASM functions that have 100% compatible behavior with EVM instructions. For example, there is an instruction in EVM called COINBASE that provides access to the block’s coinbase. ECL provides similar functionality through the _evm_coinbase function that developers can call. A more complicated example is EVM calls where developers can run EVM bytecode. We provide EVM compatible call/create function families that developers can use to deploy or run EVM bytecode. Technically, inside this ECL functions, we literally inject EVM runtime and execute bytecode as is. We understand that it can bring additional overhead of the execution and proving, but we’re working on optimizations.
- WCL (WASM Compatibility Layer) - provides functions to deploy and run WASM contracts, for example _wasm_create or _wasm_call. Deploy function translates WASM bytecode into rWASM and call function executes rWASM bytecode. This is how developers can deploy and run WASM applications.

More Compatibility Layers? Technically we can implement any CL and bring support for more binary formats like ELF+RISC-V (that is used in RiscZero), MoveVM or Solana binaries. We haven't decided yet how to route the deployer to the correct CL during deployment or function call, right now we solve it by checking binary signatures to choose the right CL, but we’re not sure that this is the most optimal decision (it creates some impossible EVMs collision that is unsafe to use, but not ideal). 

So now we know that we have following contracts and functions that are used to interact with EVM and WASM runtimes including deployment and invocation process:
- `_evm_create`
- `_evm_call`
- `_wasm_create`
- `_wasm_call`

Next question is how we manage encoding and decoding params? Because Solidity apps have a special ABI encoding format that is inefficient to use in WASM apps. We actually don’t solve this problem at all and put it on the developer's shoulders. Developer must be aware of how the app is developed and deployed (he/she literally does it right now for the Solidity interoperability because it's impossible to encode input params w/o knowing a smart contract specification). Lets check all possible interoperability cases.

- EVM -> EVM: by default EVM apps are designed to interact with EVM apps only that use the same ABI encoding standards. It means that it's safe for us to replace any EVM to EVM calls with our _evm_call function because we know that EVM to WASM interop is not designed in Solidity language at all.
- EVM -> non-EVM: in this case developers must encoding input params based on the smart contract’s ABI standards (they can be different based on the CL used) and execute the right CL contract, for example, WCL (WASM). Since the CL contract is known then the developer just calls this CL by passing required params for an app interop. For example, we have a WASM contract with function that consumes two numbers, then EVM developer encodes these two numbers according to WASM ABI encoding format (we provide libraries for Solidity and other languages) and send this information into WCL where WCL does all required prec-hecks and execute corresponding rWASM binary.
- non-EVM -> EVM: this interop is much easier because WASM apps can easily encode any ABI standards and interact with any CL contracts almost natively, plus all SDKs and libs are developed using Rust. In this case the developer just uses Solidity ABI encoding for EVM contracts and WASM ABI encoding for WASM contracts.
- non-EVM -> non-EVM: as described above WASM can natively use any encoding/decoding format to interact with any types of apps. 

The WASM ABI that I mentioned above we call Codec. It implements similar ideas as Solidity ABI, but consumes less memory. Right now redesigning this library to be more Solidity ABI compatible and more friendly for Solidity ABI encodings. Maybe we will use Solidity ABI even for WASM apps, but we haven't decided yet, it depends on benchmarks. 
