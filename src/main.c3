module gc;
import std::io;


fn int main(String[] args) {
	
    init_types();
    if (catch err = validParentheses()) {
        printFault(err);
    }
    io::printn("DONE");
	return 0;
}



