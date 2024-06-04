# Technology

rWASM is based on WASMi's IR developed by [Parity Tech](https://github.com/wasmi-labs/wasmi) and now under Robin Freyler's ownership.
We decided to choose the WASMi virtual machine because its IR is fully identical to the original WASM's opcode position.
For rWASM, we follow the same principle.
Additionally, we don't modify WASMi's IR; instead, we only modify the binary representation to achieve ZK-friendliness.

Here is a list of differences:
1. Deterministic function order based their position in the codebase
2. Block/Loop are replaced with Br-family instructions
3. Break instructions are redesigned to support PC offsets instead of depth-level
4. Most of the sections are removed to simplify binary verification
5. The new memory segment section that implements all WASM memory standards in one place
6. Removed global variables section
7. Type mapping are not required anymore since code is fully validated
8. Special entrypoint function that inits all segments

The new binary representation produces 100% valid WASMi's runtime module from binary.
There are several features that are not supported anymore, but not required by rWASM runtime:
- module, global variables and memory imports
- global variables exports

## Structure

rWASM binary format supports following sections:
1. bytecode section (it replaces function/code/entrypoint sections)
2. memory section (it replaces memory/data for all active/passive/declare section types)
3. function section (temporary solution for code section, will be removed)
4. element section (it replaces table/elem sections, will be removed)

### Bytecode section

This section replaces WASM's original function/code/start sections.

Bytecode contains all instructions for the entire binary w/o any additional separators for functions.
Functions can be recovered from a bytecode by reading function section that contains function lengths.
We inject entrypoint function in the end.
Entrypoint is used to initialize all segments according to WASM constraints.

P.S: we're planning to remove function section and store entrypoint at 0 offset.
To achieve this we need to remove stack call and implement indirect breaks.
We have implementation of this, but it's not good enough, and we're planning to migrate to register-based IR before implementing this.

### Memory section

### Function sections

### Element section



## Function order based on the position

There is no need to store information about each function inside WASM binary, like function section and code section.
Instead of can say that all bytecode is presented in a flat structure, and we store all functions as one function.
To achieve this we remove all `CallInternal` related opcodes and replace them with breaks.
To simulate function return we use new instruction `BrIndirect` that reads IP from the stack and jumps.
It means that `Return` opcode is always used only for execution termination since there is only one function.

### Function order and internal calls

For example, let's say we have two internal functions inside function and code sections.
Let it be `foo` and `bar` function.
Each internal function has position in the code section like a binary offset.
Since we know that all functions are ordered and one function code can't collide with another then we can sort all functions and replace function index with the position in the bytecode.
Let's say function `foo` has index 0 and position 120. Then we replace `CallInternal(0)` with `CallInternal(120)`.
It makes much easier to prove PC and there is no need to parse function and code sections for offset matching.

### Function local variables

Each function might have local variables.
In the reduced binary we don't store type mappings, so we need to avoid using local variables inside functions.
To fix this problem we declare that each function has zero local variables and replace function init with `i32.const 0` opcodes.

### Global variables

Global variables init we inject inside start section of the binary

## WebAssembly's problems and ways to solve them

Most complicated issues for WASM proofs relate to PC offset calculation.
Here we're defining ways how to avoid such situations by applying binary modifications that help to keep WASM compatibility but let it have more efficient binary structure.
Long story short we need to create flatten binary representation of WASM by keeping backward compatibility with instruction set.

One thing we want to highlight is that WASM is designed to be validated before execution, it means that translation step goes right after validation and translation can't go through if original WASM binary is not valid that helps us to define next statements and assumptions.
1. if WASM binary is valid then rWASM binary is valid too
2. rWASM can't store not possible instruction inside it's binary representation
3.

### Type section

Creating proof for type mappings is quite expensive because you need to create a lookup table to store information about each parsed binary type

### Global variables
### Function indices
### Memory section