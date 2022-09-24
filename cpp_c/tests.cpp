#include "binmgr.cpp"
#include <iostream>


class test {
	byte value = 120;
	byte value2 = 0;
	byte value3 = 50;
};


int main() {
	test thing;

	BitSlice bss[] = {
		{"hola"}, {12}, {&thing}, BitSlice::from_size(1), {167},
	};

	for (BitSlice& bs : bss) {
		std::cout << bs.to_string(true, true, false, true) << std::endl;
	}

	printf("\n-------------------------\n\n");

	BitSlice a = BitSlice::from_size(2);

	// set the bits to 10101010...
	for (auto bit : a) {
		bit = bit.get_index() % 2;
	}

	std::cout << a.to_string(true, false, true) << "\n";
}

