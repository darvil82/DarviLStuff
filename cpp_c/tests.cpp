#include "binmgr.cpp"
#include <iostream>


class test {
	byte value = 120;
	byte value2 = 0;
	byte value3 = 50;
};


int main() {
	test thing;
	char thing2[] = "hello";

	BitSlice bss[] = {
		{thing2}, {12}, {&thing}, BitSlice::from_size(5), {167},
	};

	// set the first bit of the third byte of "thing2" to 1.
	bss[0][2][0] = true;

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

	std::cout << a.to_string() << std::endl;

	for (auto x = a.begin_bytes(); x != a.end_bytes(); ++x) {
		printf("byte n: %zu\n", (*x).get_index());
		for (auto bit : *x) {
			printf("\tbit n: %zu = %d\n", bit.get_index(), bit.get_value());
		}
	}
}
