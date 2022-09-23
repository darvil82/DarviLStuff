#include <iostream>
#include <string>
#include <iomanip>
#include <sstream>
#include <memory.h>

#define GET_BIT(value, index) (value >> index) & 1
#define SET_BIT(value, index, new_bit_value) (value & ~(1UL << index - 1)) | (new_bit_value << index - 1)

typedef unsigned char byte;

std::string byte_to_hex(byte data) {
	std::stringstream ss;
	ss << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(data);
	return ss.str();
}

struct ResizeCustomPointerError : std::exception {
	const char* what() const noexcept override {
		return "Cannot resize custom pointer";
	}
};




class BitSlice {
	#define CHECK_BYTE_IN_BOUNDS this->check_in_bounds(index, false)
	#define CHECK_BIT_IN_BOUNDS this->check_in_bounds(index)

	bool own_ptr = true; // do we own the pointer to the bits?
	size_t size; // the size in bytes
	byte* bits;

	void check_in_bounds(size_t index, bool is_bit_index = true) const {
		size_t byte_index = is_bit_index ? index / 8 : index;

		if (byte_index >= this->size || byte_index < 0) {
			throw std::invalid_argument("Index is out of bounds");
		}
	}

	void set_size(size_t new_size) {
		if (new_size <= 0) {
			throw std::invalid_argument("Size must be greater than 0");
		}
		this->size = new_size;
	}

	class BitIterator {
	    size_t current = 0;
	    BitSlice& bs;
	public:

	    BitIterator(BitSlice& bs, size_t index = 0):
			bs{bs},
			current{index}
		{}

	    bool operator*() const {
	        return bs.get_bit(current);
	    }

		void operator++() {
			current++;
		}

		bool operator!=(BitIterator& bi) const {
			return this->current != bi.current;
		}
	};

public:
	BitSlice(): BitSlice((byte)0) {}

	template<typename T>
	BitSlice(T value):
		size{sizeof(value)},
		bits{new byte[this->size]}
	{
		memcpy(this->bits, &value, this->size);
	}

	BitSlice(const char* value, bool include_null_terminator = false):
		bits{(byte*)value},
		own_ptr{false}
	{
		this->set_size(strlen(value) + include_null_terminator);
	}

	template<typename T>
	BitSlice(T* value):
		bits{(byte*)value},
		own_ptr{false}
	{
		this->set_size(sizeof(*value));
	}



	BitSlice(const BitSlice& bs):
		bits{bs.bits},
		own_ptr{bs.own_ptr},
		size{bs.size}
	{ }

	~BitSlice() {
		if (this->own_ptr)
			delete this->bits;
	}

	static BitSlice from_size(size_t size) {
		BitSlice bs;
		bs.resize(size);
		return bs;
	}



	void resize(size_t size) {
		if (!this->own_ptr) {
			throw ResizeCustomPointerError();
		}
		this->set_size(size);
		this->bits = (byte*)realloc(this->bits, this->size);
	}

	size_t get_size() const {
		return this->size;
	}

	bool operator[](size_t index) const {
		return this->get_bit(index);
	}

	byte get_byte(size_t index) const {
		CHECK_BYTE_IN_BOUNDS;
		return this->bits[index];
	}

	void set_byte(size_t index, byte value) {
		CHECK_BYTE_IN_BOUNDS;
		this->bits[index] = value;
	}

	void set_bit(size_t index, bool value) {
		CHECK_BIT_IN_BOUNDS;
		size_t byte_index = index / 8;
		this->bits[byte_index] = SET_BIT(this->bits[byte_index], index, value);
	}

	bool get_bit(size_t index) const {
		CHECK_BIT_IN_BOUNDS;
		printf("asked to get bit index %d. Byte index: %d. Current Byte: %d. The value: %d\n", index, index / 8, this->bits[index / 8], (bool)GET_BIT(this->bits[index / 8], index));
		return GET_BIT(this->bits[index / 8], index);
	}

	std::string to_string(
		bool show_separator = false,
		bool reverse = false,
		bool show_decimal_values = false,
		bool show_hex_values = false
	) const {
		std::string temp_str;
		size_t bits = this->size * 8;

		for (size_t byte_ = 0; byte_ < this->size; byte_++) {
			byte current_byte = this->bits[reverse ? (this->size - byte_ - 1) : byte_];

			if (show_separator)
				temp_str += '|';

			for (size_t bit = 8; bit > 0; bit--) {
				temp_str += std::to_string(GET_BIT(current_byte, bit - 1));
			}

			if (show_decimal_values)
				temp_str += std::string(":") += std::to_string(current_byte);

			if (show_hex_values)
				temp_str += std::string(":") + byte_to_hex(current_byte);
		}

		return std::string("0b") += temp_str;
	}

	BitIterator begin() {
		return {*this};
	}

	BitIterator end() {
		return {*this, this->size * 8};
	}
};


class test {
	byte value = 120;
	byte value2 = 0;
	byte value3 = 50;
};


int main() {
	test thing;

	BitSlice bss[] = {
		{"hola"},
		{12},
		{&thing},
		BitSlice::from_size(1),
		{167},
	};

	for (BitSlice& bs : bss) {
		std::cout << bs.to_string(true, true, false, true) << std::endl;
	}

	BitSlice a = BitSlice::from_size(3);
	a.set_byte(0, 255);
	a.set_byte(1, 255);
	a.set_byte(2, 192);

	// iterate the bits
	for (bool bit : a) {
		std::cout << bit << ",";
	}

	std::cout << "\n" << a.get_size() << " \n";

	for (int x = 0; x < 24; x++) {
		std::cout << a[x] << ",";
	}

	std::cout << "\n" << a.to_string(true) << "\n";
}
