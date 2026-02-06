module gc;
import std::io;

faultdef ALLOCATION_FAILED,
		 STACK_OVERFLOW, 
		 STACK_POINTER_OUT_OF_RANGE,
		 DOUBLE_FREE,
		 DATA_IS_NULL,
		 TOO_MANY_HEAP_OBJECTS,
		 HEAP_OBJECTS_NULL,
         SIZE_MISMATCH,
		 TYPE_MISMATCH,
		 INCORRECT_BYTE_LENGTH,
		 CALLED_FREE_ON_STACK_MEMORY,
		 CHILDREN_NOT_FREED,
         ARRAY_INDEX_OUT_OF_BOUNDS;

fn void printFault(fault err) {
	io::printfn("Error: %s\n", err.nameof);
}

enum AllocationType {
	STACK, HEAP
}

enum ObjectType {
	SINGLE, ARRAY
}

enum OperatorType {
	PLUS, MINUS, MULTIPLY, DIVIDE
}

const usz MAX_LOCAL_COUNT = 1000;
const usz MAX_HEAP_OBJECTS = 1000;
const usz STACK_SIZE = 20000;

enum VarTypeTag {
	I32,
	F32,
	F64,
	CHAR,
	BOOL,
	UNKNOWN,
}

enum DataType : int (String name) {
    SINGLE = "Single",
    ARRAY = "Array",
    STRUCT = "Struct",
    POINTER = "Pointer",
}

VarType i32_type;
VarType f32_type;
VarType f64_type;
VarType char_type;
VarType bool_type;

fn void init_types() {
	i32_type = createVartype(VarTypeTag.I32, 4);
	f32_type = createVartype(VarTypeTag.F32, 4);
	f64_type = createVartype(VarTypeTag.F64, 8);
	char_type = createVartype(VarTypeTag.CHAR, 1);
	bool_type = createVartype(VarTypeTag.BOOL, 1);
}