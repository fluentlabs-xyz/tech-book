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

There are three main system bindings for managing context switching.

```rust
#[link(wasm_import_module = "fluentbase_v1preview")]
extern "C" {
    /// Terminates function execution with the specified exit code.
    pub fn _exit(code: i32) -> !;

    /// Executes a nested call with specified bytecode poseidon hash.
    ///
    /// # Parameters
    /// - `hash32_ptr`: A pointer to a 254-bit poseidon hash of a contract to be called.
    /// - `input_ptr`: A pointer to the input data (const u8).
    /// - `input_len`: The length of the input data (u32).
    /// - `fuel_ptr`: A mutable pointer to a fuel value (u64), consumed fuel is stored in the same
    ///   pointer after execution.
    /// - `state`: A state value (u32), used internally to maintain function state.
    ///
    /// Fuel ptr can be set to zero if you want to delegate all remaining gas.
    /// In this case sender won't get consumed gas result.
    ///
    /// # Returns
    /// - An `i32` value indicating the result of the execution,
    /// negative or zero result stands for terminated execution,
    /// but positive code stands for interrupted execution (works only for root execution level)
    pub fn _exec(
        hash32_ptr: *const u8,
        input_ptr: *const u8,
        input_len: u32,
        fuel_ptr: *mut u64,
        state: u32,
    ) -> i32;

    /// Resumes the execution of a previously suspended function call.
    ///
    /// This function is designed to handle the resumption of a function call
    /// that was previously paused.
    /// It takes several parameters that provide
    /// the necessary context and data for resuming the call.
    ///
    /// # Parameters
    ///
    /// * `call_id` - A unique identifier for the call that needs to be resumed.
    /// * `return_data_ptr` - A pointer to the return data that needs to be passed back to the
    ///   resuming function.
    /// This should point to a byte array.
    /// * `return_data_len` - The length of the return data in bytes.
    /// * `exit_code` - An integer code that represents the exit status of the resuming function.
    ///   Typically, this might be 0 for success or an error code for failure.
    /// * `fuel_ptr` - A mutable pointer to a 64-bit unsigned integer representing the fuel need to
    ///   be charged, also it puts a consumed fuel result into the same pointer
    pub fn _resume(
        call_id: u32,
        return_data_ptr: *const u8,
        return_data_len: u32,
        exit_code: i32,
        fuel_ptr: *mut u64,
    ) -> i32;
}
```