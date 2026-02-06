module gc;
import std::io;

fn Object*[13]? getHelloWorld(Stack* stack) {

    StackFrame stack_frame; 
    stack_frame.local_count = 0;
    stack_frame.original_pointer = stack.pointer;
    defer stack_frame.tagGarbage(stack);

    Object*[13] char_array;

	Object* i32_i = stack.getStackObject(i32_type)!;
    stack_frame.addLocal(i32_i)!;
    i32_i.setI32Value(0)!;

	while (i32_i.getI32Value()! < 13) {

		int i_value = i32_i.getI32Value()!;

		char_array[i_value] = stack.getHeapObject(char_type)!;

		i32_i.changeI32Value(1, OperatorType.PLUS)!;
	}

	char_array[0].setCharValue(72)!;
	char_array[1].setCharValue(101)!;
	char_array[2].setCharValue(108)!;
	char_array[3].setCharValue(108)!;
	char_array[4].setCharValue(111)!;
	char_array[5].setCharValue(44)!;
	char_array[6].setCharValue(32)!;
	char_array[7].setCharValue(87)!;
	char_array[8].setCharValue(111)!;
	char_array[9].setCharValue(114)!;
	char_array[10].setCharValue(108)!;
	char_array[11].setCharValue(100)!;
	char_array[12].setCharValue(33)!;


    return char_array;
}

fn void? stressTestGC() {

    const usz MAX_LOOP_ITERATIONS = 10000;
    Stack stack = createStack()!;
    defer stack.freeStackNoError();
	stack.print();

    usz iterations = 0;
    const usz PRINT_THRESHOLD = 500;
    usz threshold_count = 0;
    while (iterations < MAX_LOOP_ITERATIONS) {

        StackFrame stack_frame; 
        stack_frame.local_count = 0;
        stack_frame.original_pointer = stack.pointer;

        Object*[13] hello_world_array = getHelloWorld(&stack)!;
        //Hello world!
        char[13] values = {72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33};

        for (usz i = 0; i < 13; i++) {
            stack_frame.addLocal(hello_world_array[i])!;
            hello_world_array[i].setCharValue(values[i])!;
        }

        Object* i32_i = stack.getStackObject(i32_type)!;
        stack_frame.addLocal(i32_i)!;
        i32_i.setI32Value(0)!;

        if (threshold_count >= PRINT_THRESHOLD) {

            io::printfn("printing. iterations: %s", iterations);
            stack.print();
            while (i32_i.getI32Value()! < 13) {

                int i_value = i32_i.getI32Value()!;
                i32_i.printBits();

                char c = hello_world_array[i_value].getCharValue()!;
                
                io::printfn("%c", c);
                i32_i.changeI32Value(1, OperatorType.PLUS)!;
            }
            io::printn();
            threshold_count = 0;
        }
        stack_frame.tagGarbage(&stack);

        if (stack.heap.overGCThreshold() == true) {
            io::printfn("Running gc. iteration: %d", iterations);
            stack.collectGarbage()!;
            stack.print();
        }

        iterations += 1;
        threshold_count += 1;
    }
    stack.collectGarbage()!;
    stack.print();
}


fn void? allocateSomeMemory(Stack* stack) {

	StackFrame stack_frame; 
    stack_frame.local_count = 0;
    stack_frame.original_pointer = stack.pointer;

	Object* i32_heap_object = stack.getHeapObject(i32_type)!;
	stack_frame.addLocal(i32_heap_object)!;

	i32_heap_object.setI32Value(100)!;
	int value = i32_heap_object.getI32Value()!;
	io::printfn("heap value: %d", value);

	stack_frame.tagGarbage(stack);
}

fn void? testGarbageCollection() {

	Stack stack = createStack()!;
	stack.print();

	Object* i32_i = stack.getStackObject(i32_type)!;
	stack.print();

	i32_i.setI32Value(0)!;

	while (i32_i.getI32Value()! < 10) {

		allocateSomeMemory(&stack)!;
		i32_i.changeI32Value(1, OperatorType.PLUS)!;
	}

	stack.print();

	io::printn("Running garbage collection");
	stack.collectGarbage()!;
	io::printn("after garbage collection");

	stack.print();
	
	i32_i.setI32Value(0)!;

	while (i32_i.getI32Value()! < 10) {

		allocateSomeMemory(&stack)!;
		i32_i.changeI32Value(1, OperatorType.PLUS)!;
	}

	io::printn("Running garbage collection");
	stack.collectGarbage()!;
	io::printn("after garbage collection");

	stack.print();

	stack.freeStack()!;
}

fn void? basicTest() {

	Stack stack = createStack()!;
    stack.heap.heap_object_count = 0;
    defer stack.freeStack()!!;

	stack.print();

	Object* i32_i = stack.getStackObject(i32_type)!;
	stack.print();

	//Hello, World!
	Object*[13] char_array;

	i32_i.setI32Value(0)!;

	while (i32_i.getI32Value()! < 13) {

		int i_value = i32_i.getI32Value()!;

		char_array[i_value] = stack.getStackObject(char_type)!;

		i32_i.changeI32Value(1, OperatorType.PLUS)!;
	}
	stack.print();

	char_array[0].setCharValue(72)!;
	char_array[1].setCharValue(101)!;
	char_array[2].setCharValue(108)!;
	char_array[3].setCharValue(108)!;
	char_array[4].setCharValue(111)!;
	char_array[5].setCharValue(44)!;
	char_array[6].setCharValue(32)!;
	char_array[7].setCharValue(87)!;
	char_array[8].setCharValue(111)!;
	char_array[9].setCharValue(114)!;
	char_array[10].setCharValue(108)!;
	char_array[11].setCharValue(100)!;
	char_array[12].setCharValue(33)!;

	i32_i.setI32Value(0)!;

	while (i32_i.getI32Value()! < 13) {

		int i_value = i32_i.getI32Value()!;

		char c = char_array[i_value].getCharValue()!;

		io::printf("%c", c);
		i32_i.changeI32Value(1, OperatorType.PLUS)!;
	}
	io::printn();

	Object* i32_heap_object = stack.getHeapObject(i32_type)!;
	i32_heap_object.setI32Value(100)!;
	io::printn("Created heap memory");
	stack.print();

	io::printfn("heap_object: %d", i32_heap_object.getI32Value()!);

	i32_heap_object.freeObject()!;

	io::printn("Freed heap memory");
	stack.print();


	io::printn("Freed stack memory");
	stack.print();
}

fn void? testingArrays() {
    Stack stack = createStack()!;
    stack.heap.heap_object_count = 0;
    defer stack.freeStackNoError();

    stack.print();
    io::printfn("stack pointer: %d", stack.data);
    io::printfn("max pointer: %d", stack.data + STACK_SIZE);

    StackFrame stack_frame;
    stack_frame.local_count = 0;
    stack_frame.original_pointer = stack.pointer;

    Object* array = stack.getStackArrayObject(char_type, 12)!;
    stack_frame.addLocal(array)!;
    stack.print();
    Object* array_object = (Object*)array.getPointerValue()!;

    array_object.setCharArrayValue('H', 0)!;
    array_object.setCharArrayValue('e', 1)!;
    array_object.setCharArrayValue('l', 2)!;
    array_object.setCharArrayValue('l', 3)!;
    array_object.setCharArrayValue('o', 4)!;
    array_object.setCharArrayValue(' ', 5)!;
    array_object.setCharArrayValue('W', 6)!;
    array_object.setCharArrayValue('o', 7)!;
    array_object.setCharArrayValue('r', 8)!;
    array_object.setCharArrayValue('l', 9)!;
    array_object.setCharArrayValue('d', 10)!;
    array_object.setCharArrayValue('!', 11)!;
    int value_0 = array_object.getCharArrayValue(0)!;
    io::printfn("value_0: %c", value_0);

    stack.print();

    Object* array_holder = stack.getHeapArrayObject(i32_type, 5)!;
    stack_frame.addLocal(array_holder)!;
    Object* heap_array = (Object*)array_holder.getPointerValue()!;
    stack.print();
    heap_array.setI32ArrayValue(1, 0)!;
    heap_array.setI32ArrayValue(2, 1)!;
    heap_array.setI32ArrayValue(3, 2)!;
    heap_array.setI32ArrayValue(4, 3)!;
    heap_array.setI32ArrayValue(5, 4)!;
    for (int i = 0; i < 5; i++) {
        int value = heap_array.getI32ArrayValue(i)!;
        io::printfn("\tvalue: %d", value);
    }
    stack_frame.tagGarbage(&stack);
    stack.print();
    stack.collectGarbage()!;
    stack.print();
}

fn void? testingStack() {
	Stack stack = createStack()!;
    stack.heap.heap_object_count = 0;
    defer stack.freeStack()!!;
	
	stack.print();
	
	int value = 0;

	io::printn("Creating A:");
	Object* i32_a = stack.getStackObject(i32_type)!;
	i32_a.setI32Value(0)!;
	
	stack.print();
	
	io::printn("Looping a");
	while (i32_a.getI32Value()! < 10) {
		value = i32_a.getI32Value()!;
		io::printfn("%d", value);
		i32_a.changeI32Value(1, OperatorType.PLUS)!;
	}
	
	stack.print();
	
	io::printn("Creating char array");
	Object* char_array = stack.getStackArrayObject(char_type, 5)!;
	Object* array_object = (Object*)char_array.getPointerValue()!;
	
	io::printn("Setting values:");
	array_object.setCharArrayValue('H', 0)!;
	array_object.setCharArrayValue('e', 1)!;
	array_object.setCharArrayValue('l', 2)!;
	array_object.setCharArrayValue('l', 3)!;
	array_object.setCharArrayValue('o', 4)!;
	
	io::printn("After values:");
	
	stack.print();
	
	io::printn("Creating B:");
	Object* i32_b = stack.getStackObject(i32_type)!;
	i32_b.setI32Value(0)!;
	
	stack.print();
	
	io::printn("Looping b");
	while (i32_b.getI32Value()! < 10) {
		value = i32_b.getI32Value()!;
		io::printfn("%d", value);
		i32_b.changeI32Value(1, OperatorType.PLUS)!;
	}
	
	stack.print();
	
	io::printn("Creating C:");
	Object* i32_c = stack.getStackObject(i32_type)!;
	i32_c.setI32Value(0)!;
	
	stack.print();
	
	io::printn("Looping c");
	while (i32_c.getI32Value()! < 10) {
		value = i32_c.getI32Value()!;
		io::printfn("%d", value);
		i32_c.changeI32Value(1, OperatorType.PLUS)!;
	}
	
	stack.print();
	
	io::printn("Creating d:");
	Object* i32_d = stack.getStackObject(i32_type)!;
	i32_d.setI32Value(0)!;
	
	stack.print();
	
	io::printn("Looping d");
	while (i32_d.getI32Value()! < 10) {
		value = i32_d.getI32Value()!;
		io::printfn("%d", value);
		i32_d.changeI32Value(1, OperatorType.PLUS)!;
	}
	
	stack.print();
	
	io::printn("Creating e");
	Object* i32_e = stack.getStackObject(i32_type)!;
	i32_e.setI32Value(0)!;
	
	stack.print();
	
	io::printn("Looping e");
	while (i32_e.getI32Value()! < 10) {
		value = i32_e.getI32Value()!;
		io::printfn("%d", value);
		i32_e.changeI32Value(1, OperatorType.PLUS)!;
	}
	
	stack.print();
	
	io::printfn("a: %d\nb: %d\nc: %d\nd: %d\ne: %d", 
		i32_a.getI32Value()!,
		i32_b.getI32Value()!,
		i32_c.getI32Value()!,
		i32_d.getI32Value()!,
		i32_e.getI32Value()!,
	);
}