module gc;
import std::io;

struct Stack {
	char* data;
	usz pointer;
	usz heap_allocations;
	usz heap_frees;

	Heap heap;
}

fn Stack? createStack() {
    Stack stack;
    const usz BYTES = char.sizeof * STACK_SIZE;
	stack.data = (char*)malloc(BYTES);
	if (stack.data == null) {
        return ALLOCATION_FAILED?;
	}
	stack.pointer = 0;
    Heap heap;
	stack.heap = heap;
    return stack;
}

fn Object*? Stack.getStackObject(Stack* self, VarType var_type) {

	if (self.data == null) {
		return DATA_IS_NULL?;
	}

	usz required = Object.sizeof + var_type.size_in_bytes;

	if (self.pointer + required > STACK_SIZE) {
		return STACK_OVERFLOW?;
	}

	Object* object = self.allocObject()!;

	object.data = self.data + self.pointer;
    self.pointer += var_type.size_in_bytes;

	object.size_in_bytes = var_type.size_in_bytes;
	object.var_type = var_type;
	object.allocation_type = AllocationType.STACK;
	object.child_count = 0;
	object.has_stack_reference = false;

	return object;
}

fn Object*? Stack.getHeapObject(Stack* self, VarType type) {

	if (self.data == null) {
		return DATA_IS_NULL?;
	}

	usz required = Object.sizeof;

	if (self.pointer + required > STACK_SIZE) {
		return STACK_OVERFLOW?;
	}

	Object* object = self.allocObject()!;

	object.data = (char*)malloc(type.size_in_bytes);
	self.heap_allocations += 1;
	object.var_type = type;
	object.size_in_bytes = type.size_in_bytes;
	object.allocation_type = AllocationType.HEAP;
	object.child_count = 0;
	object.has_stack_reference = true;
	self.heap.addHeapObject(object)!;
	return object;
}

fn usz alignForward(usz ptr, usz alignment) {
    return (ptr + alignment - 1) & ~(alignment - 1);
}

const usz OBJECT_ALIGNMENT = 8;

fn Object*? Stack.allocObject(Stack* self) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }

    self.pointer = mem::aligned_offset(self.pointer, OBJECT_ALIGNMENT);

    if (self.pointer + Object.sizeof > STACK_SIZE) {
        return STACK_OVERFLOW?;
    }

    Object* obj = (Object*)(self.data + self.pointer);
    self.pointer += Object.sizeof;

    assert(mem::ptr_is_aligned(obj, OBJECT_ALIGNMENT));

    return obj;
}

fn Object*? Stack.getStackArrayObject(Stack* self, VarType type, usz child_count) {

    if (self.data == null) {
		return DATA_IS_NULL?;
	}

    usz array_bytes = type.size_in_bytes * child_count;
	usz required_bytes =  
        Object.sizeof +      // holder
        Object.sizeof +      // child
        array_bytes;

	if (self.pointer + required_bytes > STACK_SIZE) {
		return STACK_OVERFLOW?;
	}

	Object* holder_object = self.allocObject()!;
    Object* child_object = self.allocObject()!;

    char* array_data = (char*)(self.data + self.pointer);
    self.pointer += array_bytes;

    child_object.data = array_data;
    child_object.var_type = type;
    child_object.size_in_bytes = array_bytes;
    child_object.data_type = DataType.ARRAY;
    child_object.allocation_type = AllocationType.STACK;
    child_object.has_stack_reference = false;
    child_object.child_count = child_count;

    holder_object.data = (char*)child_object;
	holder_object.var_type = type;
	holder_object.size_in_bytes = Object*.sizeof;
    holder_object.child_count = 0;
	holder_object.allocation_type = AllocationType.STACK;
	holder_object.has_stack_reference = false;
    holder_object.data_type = DataType.POINTER;
	return holder_object;
}
fn Object*? Stack.getHeapArrayObject(Stack* self, VarType type, usz child_count) {

    if (self.data == null) {
		return DATA_IS_NULL?;
	}

	usz required_bytes = Object.sizeof + Object*.sizeof;

	if (self.pointer + required_bytes > STACK_SIZE) {
		return STACK_OVERFLOW?;
	}

	Object* holder_object = self.allocObject()!;
    Object* child_object = self.allocObject()!;

    usz array_bytes = type.size_in_bytes * child_count;
    char* array_data = (char*)malloc(type.size_in_bytes * child_count);
    if (array_data == null) {
        return ALLOCATION_FAILED?;
    }

    self.heap_allocations += 1;

    child_object.data = array_data;
    child_object.var_type = type;
    child_object.size_in_bytes = array_bytes;
    child_object.data_type = DataType.ARRAY;
    child_object.has_stack_reference = true;
    child_object.child_count = child_count;
    child_object.allocation_type = AllocationType.HEAP;
    self.heap.addHeapObject(child_object)!;

    holder_object.data = (char*)child_object;
	holder_object.var_type = type;
	holder_object.size_in_bytes = Object*.sizeof;
    holder_object.child_count = 0;
	holder_object.allocation_type = AllocationType.STACK;
	holder_object.has_stack_reference = false;
    holder_object.data_type = DataType.POINTER;
	return holder_object;
}

fn void? Stack.collectGarbage(Stack* self) {
    self.heap_frees += self.heap.collectHeapGarbage()!;
}

fn void Stack.print(Stack* self) {
    io::printn("\n\tPrinting stack data:");
    if (self.data == null) {
        io::printn("\t\tData: NULL");
    } else {
        io::printn("\t\tData: valid");
    }
    io::printfn("\t\tPointer: %d", self.pointer);
    io::printfn("\t\tallocations: %d", self.heap_allocations);
    io::printfn("\t\tfrees: %d", self.heap_frees);
    io::printn("\tHeap:");
    io::printfn("\t\theap_object_count: %d", self.heap.heap_object_count);
    io::printfn("\t\tallocated bytes: %d", self.heap.allocated_memory);
    io::printn();
}

fn void? Stack.freeStack(Stack* self) {
    if (self.data == null) {
        return DOUBLE_FREE?;
    }
    free(self.data);
    self.data = null;
    self.pointer = 0;
}

fn void Stack.freeStackNoError(Stack* self) {
    if (self.data == null) {
        return;
    }
    free(self.data);
    self.data = null;
    self.pointer = 0;
}

