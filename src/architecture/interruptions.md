# Interruptions

Fluent interoperability relies heavily on its interruption system.
In Fluent L2, smart contracts and applications are limited to pure functions,
preventing system calls from accessing external resources such as bytecodes,
cold or invalidated storage slots, or performing nested calls.
Including system calls imposes additional proving overhead, as proving gadgets must be developed for each call,
complicating system development.
This also impacts the flexibility in managing rights or extending contracts,
making the system less sustainable for the fork-less concept.
In such a scenario, system contracts cannot be upgraded without updating the circuits.

We solve the problem
by enabling an interruption system
that helps to manage context switching between nested apps and the so-called root-STF that stands for context management.

For simplicity, let's assume that root-STF, smart contracts, EE, and applications are all functions (since they are essentially state transition functions).

Functions can be categorized as either root or non-root.
A **root function** is defined as a function where the depth level is equal to 0.
The root function (referred to as `root-STF`) is pivotal because it handles all context switching and cross-contract accesses,
serving as a security layer.

The root function has the ultimate authority over all state transitions within the blockchain.
Consequently, it is fully managed by the Fluent team.
Additionally, the root function is in charge of managing and executing system calls.
The root function cannot be interrupted, but it is capable of handling interruptions.

## System Bindings

The system bindings manage context switching in Fluent's interruption system. The following functions are provided:
1. `_exec(..)` - execute bytecode
2. `_resume(..)` - resume interrupted state
3. `_exit(..)` - exit contract

### Application Exit

Terminates function execution with the specified exit code.
The function is designed to exit from any smart contract or application.
It immediately halts the contract execution and forwards all execution results,
including the exit code and return data, to the caller contract.

```rust
pub fn _exit(code: i32) -> !;
```

**Constraints:**
The exit code must always be a negative 32-bit integer.
Supplying a positive exit code will result in a `NonNegativeExitCode` execution error.
Positive exit codes indicate interrupted execution and are exclusive to the `_exec` or `_resume` functions.

![img.png](../../images/exit-flow.png)

```sequence
title Application Exit Flow

activate root-STF
root-STF->SmartContract:call smart contract
activate SmartContract
SmartContract-->root-STF:exit with code
deactivate SmartContract
deactivate root-STF
```

### Execute Bytecode or Send Interruption

Execute a nested call with the specified bytecode poseidon hash.
Or send an interruption to the parent execution call though context switching.
If the depth level is greater than 0 then, does interruption otherwise execute bytecode.

**Parameters**:

- `hash32_ptr`: A pointer to a 254-bit poseidon hash of a contract to be called.
- `input_ptr`: A pointer to the input data (const u8).
- `input_len`: The length of the input data (u32).
- `fuel_ptr`: A mutable pointer to a fuel value (u64). The consumed fuel is stored in the same pointer after execution.
- `state`: A state value (u32), used internally to maintain function state.

**Returns**:

- An `i32` value indicating the result of the execution. A negative or zero result stands for terminated execution,
  while a positive code stands for interrupted execution (works only for root execution level).

```rust
pub fn _exec(
    hash32_ptr: *const u8,
    input_ptr: *const u8,
    input_len: u32,
    fuel_ptr: *mut u64,
    state: u32,
) -> i32;
```

![img.png](../../images/exec-flow.png)

```sequence
title Application Exec/Resume Flow

activate root-STF
root-STF->A:call contract A\nusing _exec() func
activate A
A->A:call contract B using\n_exec() func
A-->root-STF:interrupt execution\nwith saved context
deactivate A
activate B
root-STF->B: call contract B using _exec() func
B->B: call _exit func to\nhalt execution
B-->root-STF: halt with exit code
deactivate B
root-STF->A: resume A call\nusing _resume() func
activate A
A->A: call _exit func to\nhalt execution
A-->root-STF: exit with exit code
deactivate A
deactivate root-STF
```

#### Resume Execution

Resumes the execution of a previously suspended function call.

**Parameters**:

- `call_id`: A unique identifier for the call that needs to be resumed.
- `return_data_ptr`: A pointer to the return data that needs to be passed back to the resuming function. This should
  point to a byte array.
- `return_data_len`: The length of the return data in bytes.
- `exit_code`: An integer code that represents the exit status of the resuming function. Typically, this might be 0 for
  success or an error code for failure.
- `fuel_ptr`: A mutable pointer to a 64-bit unsigned integer representing the fuel needed to be charged. The consumed
  fuel result is also stored in the same pointer.

**Returns**:

- An `i32` value indicating the result of the resumption.

```rust
pub fn _resume(
    call_id: u32,
    return_data_ptr: *const u8,
    return_data_len: u32,
    exit_code: i32,
    fuel_ptr: *mut u64,
) -> i32;
```