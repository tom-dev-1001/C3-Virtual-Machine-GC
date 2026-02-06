module gc;
import std::io;

const usz MAX_BYTES = 10000;
const usz HEAP_OBJECT_COUNT_GC_THRESHOLD = 900;

struct Heap {
	
	Object*[MAX_HEAP_OBJECTS] heap_objects;
	usz heap_object_count;
    ulong allocated_memory;
}

fn void? Heap.addHeapObject(Heap* self, Object* object_ptr) {

    if (self.heap_object_count + 1 > MAX_HEAP_OBJECTS) {
        return TOO_MANY_HEAP_OBJECTS?;
    }
    self.heap_objects[self.heap_object_count] = object_ptr;
    self.allocated_memory += object_ptr.size_in_bytes;
    self.heap_object_count += 1;
}
fn usz? Heap.collectHeapGarbage(Heap* self) {

    usz free_count = 0;
    usz write_index = 0;
	
    for (usz read_index = 0; read_index < self.heap_object_count; read_index++) {

        Object* obj = self.heap_objects[read_index];
        if (obj == null) {
            continue;
        }

        if (obj.has_stack_reference == true) {
            self.heap_objects[write_index] = obj;
            write_index += 1;
            continue;
        }
        obj.freeObject()!;
        self.decreaseAllocatedMemory(obj.size_in_bytes);
        free_count++;
    }

    self.heap_object_count = write_index;
    return free_count;
}
fn void Heap.decreaseAllocatedMemory(Heap* self, usz size_in_bytes) {
    if (self.allocated_memory < size_in_bytes) {
        self.allocated_memory = 0;
        return;
    }
    self.allocated_memory -= size_in_bytes;
}
fn bool Heap.overGCThreshold(Heap* self) {
    if (self.allocated_memory >= MAX_BYTES) {
        return true;
    }
    if (self.heap_object_count >= HEAP_OBJECT_COUNT_GC_THRESHOLD) {
        return true;
    }
    return false;
}