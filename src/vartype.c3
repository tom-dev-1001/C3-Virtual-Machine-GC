module gc;

struct VarType {
	VarTypeTag tag;
	usz size_in_bytes;
}

fn VarType createVartype(VarTypeTag tag, usz size) {
    VarType var_type;
    var_type.size_in_bytes = size;
    var_type.tag = tag;
    return var_type;
}