module gc;
import std::io;

struct Object {
	VarType var_type;
	
	AllocationType allocation_type;
    DataType data_type;
	
    usz child_count;
	bool has_stack_reference;
	
	usz size_in_bytes;
	char* data;
}

fn void Object.copyValues(Object* self, Object input_object) {
    self.var_type = input_object.var_type;
    self.child_count = input_object.child_count;
    self.size_in_bytes = input_object.size_in_bytes;
    if (input_object.data == null) {
        return;
    }
    if (self.data == null) {
        return;
    }
    for (usz i = 0; i < self.size_in_bytes; i++) {
        self.data[i] = input_object.data[i];
    }
}

fn void Object.printBits(Object* self) {

    for (usz i = 0; i < self.size_in_bytes; i++) {

        for (int bit = 7; bit >= 0; bit--) {
            char value = (self.data[i] >> bit) & 1;
            if (value != 0) {
                io::printf("%c", '1');
                continue;
            } 
            io::printf("%c", '0');
        }
        io::printn();
    }
    io::printn();
}

fn void Object.printData(Object* self) {

    bool data_is_null = self.data == null;

    io::printfn("Data:\n\tType: %s\n\tchild count: %d\n\thas stack reference: %b\n\tsize in bytes: %d\n\tdata is null %b",
        self.var_type.tag,
        self.child_count,
        self.has_stack_reference,
        self.size_in_bytes,
        data_is_null
    );
}

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
fn void? Object.setI32Value(Object* self, int value) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 4) {
        return TYPE_MISMATCH?;
    }

    //static_cast to keep all the bits the same
    uint unsigned_value = (uint)(value);

    for (usz i = 0; i < 4; i++) {
        usz shift_offset = i * 8;
        //bits 111111110000000...
        usz bit_mask = 255;
        self.data[i] = (char)((ulong)(unsigned_value >> shift_offset) & bit_mask);
    }
}
fn void? Object.changeI32Value(Object* self, int value, OperatorType operator_type) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 4) {
        return TYPE_MISMATCH?;
    }

    int new_value = self.getI32Value()!;
    switch (operator_type) {

        case OperatorType.PLUS:
            new_value += value;
            break;
        case OperatorType.MINUS:
            new_value -= value;
            break;
        case OperatorType.MULTIPLY:
            new_value *= value;
            break;
        case OperatorType.DIVIDE:
            new_value /= value;
            break;
        default:
            break;
    }

    //static_cast to keep all the bits the same
    uint unsigned_value = (uint)(new_value);

    for (usz i = 0; i < 4; i++) {
        usz shift_offset = i * 8;
        //bits 111111110000000...
        usz bit_mask = 255;
        self.data[i] = (char)((ulong)(unsigned_value >> shift_offset) & bit_mask);
    }
}
fn int? Object.getI32ArrayValue(Object*self, usz index) {
    
    io::printn("\ngetI32ArrayValue");
    
    if (self.data == null) {
        io::printn("\tdata is null");
        return DATA_IS_NULL?;
    }
    if ((self.size_in_bytes / self.child_count) != 4) {
        io::printfn("\tsize in bytes != 4, size: %d", self.size_in_bytes);
        return SIZE_MISMATCH?;
    }
    if (self.data_type != DataType.ARRAY) {
        io::printfn("\tdata type != array, type: %d", self.data_type.ordinal);
        return TYPE_MISMATCH?;
    }

    usz elem_size = self.size_in_bytes / self.child_count;
    char* pointer_offset = self.data + elem_size * index;
    io::printfn("\tself.data: %d", self.data);
    io::printfn("\tsize_in_bytes: %d", self.size_in_bytes);
    io::printfn("\tindex: %d", index);
    io::printfn("\tpointer offset: %d", pointer_offset);

    uint result = 0;

    for (usz i = 0; i < 4; i++) {
        result |= (uint)(pointer_offset[i]) << (i * 8);
    }
    return (int)(result);
}
fn void? Object.setI32ArrayValue(Object*self, int value, usz index) {

    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 4 * self.child_count) {
        return SIZE_MISMATCH?;
    }
    if (self.data_type != DataType.ARRAY) {
        return TYPE_MISMATCH?;
    }
    if (index >= self.child_count) {
        return ARRAY_INDEX_OUT_OF_BOUNDS?;
    }
    uint unsigned_value = (uint)(value);
    usz element_size = self.size_in_bytes / self.child_count;
    char* pointer_offset = self.data + element_size * index;

    for (usz i = 0; i < 4; i++) {
        usz shift_offset = i * 8;
        //bits 111111110000000...
        usz bit_mask = 255;
        pointer_offset[i] = (char)((ulong)(unsigned_value >> shift_offset) & bit_mask);
    }
}
fn void? Object.setI32ArrayValueDebug(Object*self, int value, usz index) {
    io::printn("\nsetI32ArrayValue");
    if (self.data == null) {
        io::printn("\tdata is null");
        return DATA_IS_NULL?;
    }
    io::printfn("\tdata: %p", self.data);
    if (self.size_in_bytes != 4 * self.child_count) {
        io::printn("\tbytes != array size");
        return SIZE_MISMATCH?;
    }
    if (self.data_type != DataType.ARRAY) {
        io::printn("\tnot array");
        return TYPE_MISMATCH?;
    }
    if (index >= self.child_count) {
        io::printn("\tindex out of bounds");
        return ARRAY_INDEX_OUT_OF_BOUNDS?;
    }
    io::printn("\tno errors");
    uint unsigned_value = (uint)(value);
    io::printfn("\tunsigned value %d", unsigned_value);
    io::printfn("\tdata: %p", self.data);
    usz element_size = self.size_in_bytes / self.child_count;
    char* pointer_offset = self.data + element_size * index;
    io::printfn("\tself.data: %p", self.data);
    io::printfn("\tsize_in_bytes: %d", self.size_in_bytes);
    io::printfn("\tindex: %d", index);
    io::printfn("\tpointer offset: %d", pointer_offset);
    io::printfn("\tvalue set: %d", value);

    for (usz i = 0; i < 4; i++) {
        usz shift_offset = i * 8;
        //bits 111111110000000...
        usz bit_mask = 255;
        pointer_offset[i] = (char)((ulong)(unsigned_value >> shift_offset) & bit_mask);
    }
}

fn bool? Object.getBoolValue(Object* self) {

    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 1) {
        return TYPE_MISMATCH?;
    }

    if (*self.data == 0) {
        return false;
    }
    return true;
}
fn void? Object.setBoolValue(Object* self, bool value) {

    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 1) {
        return TYPE_MISMATCH?;
    }
    if (value == false) {
        *self.data = 0;
        return;
    }
    *self.data = 1;
}

fn void? Object.setCharValue(Object* self, char value) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 1) {
        return TYPE_MISMATCH?;
    }

    *self.data = value;
}
fn char? Object.getCharValue(Object* self) {

    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 1) {
        return TYPE_MISMATCH?;
    }

    return (char)(*self.data);
}
fn char? Object.getCharArrayValue(Object*self, usz index) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != self.child_count) {
        return TYPE_MISMATCH?;
    }
    if (self.data_type != DataType.ARRAY) {
        return TYPE_MISMATCH?;
    }

    char* pointer_offset = self.data + self.size_in_bytes * index;
    return (char)(*pointer_offset);
}
fn char? Object.getCharArrayValueDebug(Object*self, usz index) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != self.child_count) {
        return TYPE_MISMATCH?;
    }
    if (self.data_type != DataType.ARRAY) {
        return TYPE_MISMATCH?;
    }

    char* pointer_offset = self.data + self.size_in_bytes * index;
    io::printfn("self.data: %d", self.data);
    io::printfn("size_in_bytes: %d", self.size_in_bytes);
    io::printfn("index: %d", index);
    io::printfn("pointer offset: %d", pointer_offset);
    return (char)(*pointer_offset);
}
fn void? Object.setCharArrayValue(Object*self, char value, usz index) {
    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != self.child_count) {
        return TYPE_MISMATCH?;
    }
    if (self.data_type != DataType.ARRAY) {
        return TYPE_MISMATCH?;
    }
    if (index >= self.child_count) {
        return ARRAY_INDEX_OUT_OF_BOUNDS?;
    }
    uint unsigned_value = (uint)(value);
    char* pointer_offset = self.data + self.size_in_bytes * index;
    *pointer_offset = value;
}
fn char*? Object.getPointerValue(Object*self) {

    if (self.data == null) {
        return DATA_IS_NULL?;
    }
    if (self.size_in_bytes != 8) {
        return TYPE_MISMATCH?;
    }
    return self.data;
}

fn void? Object.freeObject(Object* self) {
    if (self.data == null) {
        return;
    }
    if (self.allocation_type != AllocationType.HEAP) {
        return CALLED_FREE_ON_STACK_MEMORY?;
    }
    free(self.data);
    self.data = null;
}

fn void Object.markObject(Object* self) {

	if (self == null) {
		return;
	}
    if (self.child_count != 0) {
        Object* children = (Object*)self.data;
        children.markObject();
    }
    if (self.has_stack_reference == false) {
		return; // already visited
	}

	self.has_stack_reference = false;
}
