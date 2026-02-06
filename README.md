
**C3 Virtual Machine & Garbage Collector**

This project is an experimental virtual machine and runtime system written in C3, built to explore manual memory management, garbage collection, stack simulation, and low-level execution models.

The VM implements:

A manual stack model
- A heap allocator
- A reference-counted garbage collector
- Explicit object representation and memory layout
- Raw bit-level data access

The main goal is to understand and implement how language runtimes actually work internally, rather than relying on existing runtime systems.

**Core Features**
**Virtual Stack**

A custom stack implementation built on top of raw byte arrays.

- Stack frames manually created and destroyed
- Local variables explicitly tracked
- Precise lifetime control
- No reliance on host language stack

Each stack frame stores:
- Original stack pointer
- Local variable references
- Automatic garbage tagging on scope exit

This allows deterministic lifetime tracking and precise garbage collection triggering.

**Heap & Memory Management**

Objects are allocated manually with full control over:
- Memory layout
- Alignment
- Object metadata
- Lifetime tracking

Each object is represented by:
```c
struct Object {
    VarType var_type;
    AllocationType allocation_type;
    DataType data_type;

    usz child_count;
    bool has_stack_reference;

    usz size_in_bytes;
    char* data;
}
```

This allows:
- Arbitrary data types
- Dynamic object sizing
- Explicit tracking of references
- Direct bit-level manipulation

**Garbage Collector**

A reference-counting garbage collector built entirely from scratch.

Key characteristics:
- Stack roots explicitly tracked
- Automatic cleanup when stack frames exit
- Heap threshold detection
- On-demand garbage collection
The GC system:
- Tracks object lifetimes
- Detects unreachable objects
- Frees memory deterministically
- Avoids hidden allocations or implicit behavior

Garbage collection can be triggered manually or automatically when heap thresholds are exceeded.

**Raw Bit-Level Data Access**

Primitive values are stored as raw bytes.

Example: reading a 32-bit integer from memory:
```C
fn int? Object.getI32Value(Object* self) {

    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 4) {
        return TYPE_MISMATCH?;
    }

    uint result = 0;

    for (usz i = 0; i < 4; i++) {
        result |= (uint)(self.data[i]) << (i * 8);
    }

    return (int)(result);
}
```

Writing:
```C
fn void? Object.setI32Value(Object* self, int value) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 4) {
        return TYPE_MISMATCH?;
    }

    //casting to keep all the bits the same
    uint unsigned_value = (uint)(value);

    for (usz i = 0; i < 4; i++) {
        usz shift_offset = i * 8;
        //bits 111111110000000...
        usz bit_mask = 255;
        self.data[i] = (char)((ulong)(unsigned_value >> shift_offset) & bit_mask);
    }
}
```

All primitives are encoded and decoded manually using raw bit operations.

This mirrors how real runtimes manipulate data internally.

**Execution Model**

The VM uses:
- Explicit stack frame construction
- Manual object allocation
- Deterministic cleanup
- Controlled garbage collection triggers

Example: Stack frame lifecycle
```c
StackFrame frame;
frame.local_count = 0;
frame.original_pointer = stack.pointer;
defer frame.tagGarbage(&stack);
```

Local variables must be manually registered:
```c
Object* i = stack.getStackObject(i32_type)!;
frame.addLocal(i)!;
```

This provides:
- Precise root tracking
- Accurate GC behavior
- Zero hidden lifetimes

**Stress Test & GC Validation**

The VM includes a stress test that:
- Repeatedly allocates objects
- Builds arrays
- Writes raw data
- Forces GC cycles
- Prints stack + heap state

This validates:
- Reference tracking correctness
- Garbage collector reliability
- Heap stability under pressure

The test repeatedly constructs "Hello, World!" using heap-allocated character objects, forcing continuous allocation and cleanup.

**Design Goals**

This project prioritizes:
- Correctness over convenience
- Explicitness over abstraction
- Understanding over performance
- Transparency over safety nets

Nothing is hidden.
Nothing is automatic.
Everything is explicit.

**Why C3?**

C3 provides:
- C-like control
- Stronger safety
- Better ergonomics
- Cleaner error handling
This makes it ideal for:
- Low-level runtime development
- VM design
- Memory experiments
- Systems prototyping

**Project Purpose**

This VM is not meant to be production-ready.

Its purpose is:
- To explore how language runtimes actually work
- To understand memory management at a fundamental level
- To experiment with GC design
- To validate low-level execution models

This is a learning and research project focused on deep systems understanding, not usability.

**Summary**

This project implements a fully manual execution environment:
- Virtual stack
- Heap allocator
- Reference-counting GC
- Raw object layout
- Bit-level data encoding

All written from scratch.

It is essentially a runtime laboratory for exploring how programming languages operate beneath their abstractions.
