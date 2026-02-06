module gc;
import std::io;

struct StackFrame {
	usz original_pointer;
	Object*[MAX_LOCAL_COUNT] locals;
	usz local_count;
}

fn void? StackFrame.addLocal(StackFrame* self, Object* object) {
    if (self.local_count > MAX_LOCAL_COUNT) {
        return STACK_OVERFLOW?;
    }
    self.locals[self.local_count] = object;
    self.local_count += 1;
}
fn void StackFrame.tagGarbage(StackFrame* self, Stack* stack) {

    usz tag_count = 0;
    for (usz i = 0; i < self.local_count; i++) {

        Object* object = self.locals[i];
        if (object == null) {
            continue;
        }
        if (object.allocation_type != AllocationType.HEAP) {
            continue;
        }
        tag_count += 1;
        object.markObject();
    }
    //io::printfn("tagged: %d", tag_count);
    stack.pointer = self.original_pointer;
}