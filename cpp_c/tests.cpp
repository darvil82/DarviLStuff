#include "binmgr.cpp"
#include <iostream>


class test {
	byte value = 120;
	byte value2 = 0;
	byte value3 = 50;
};


int main() {
	test thing;
	const char thing2[] = "hello";

	BitSlice bss[] = {
		{thing2}, {12}, {&thing}, BitSlice::from_size(1), {167},
	};

	bss[0][16] = 1;

	for (BitSlice& bs : bss) {
		std::cout << bs.to_string(true, true, false, true) << std::endl;
	}

	printf("thing2: %s", thing2);

	printf("\n-------------------------\n\n");

	BitSlice a = BitSlice::from_size(2);

	// set the bits to 10101010...
	for (auto bit : a) {
		bit = bit.get_index() % 2;
	}

	std::cout << a.to_string(true) << std::endl;
}

