#include <iostream>
#include <string>
#include <iomanip>
#include <sstream>
#include <memory.h>

#define GET_BIT(value, index) (value >> index) & 1
#define SET_BIT(value, index, new_bit_value) (value & ~(1UL << index - 1)) | (new_bit_value << index - 1)


inline std::string char_to_hex(unsigned char data) {
	std::stringstream ss;
	ss << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(data);
	return ss.str();
}




struct IndexOutOfBoundsError : std::exception {
	const char* what() const noexcept override {
		return "Index is out of bounds";
	}
};

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
	char* bits;

	void check_in_bounds(size_t index, bool is_bit_index = true) const {
		if (is_bit_index) {
			size_t byte_index = byte_index_from_bit(index);

			if (byte_index + 1 > this->size || byte_index < 0) {
				throw IndexOutOfBoundsError();
			}
		} else {
			if (index > this->size - 1 || index < 0) {
				throw IndexOutOfBoundsError();
			}
		}
	}

	size_t byte_index_from_bit(size_t bit_index) const {
		return bit_index / (this->size * 8);
	}

	void set_size(size_t new_size) {
		if (new_size <= 0) {
			throw std::invalid_argument("Size must be greater than 0");
		}
		this->size = new_size;
	}

public:
	BitSlice(): BitSlice((char)0) {}

	template<typename T>
	BitSlice(T value):
		size{sizeof(value)},
		bits{new char[this->size]}
	{
		memcpy(this->bits, &value, this->size);
	}

	BitSlice(const char* value, bool include_null_terminator = false):
		bits{(char*)value},
		own_ptr{false}
	{
		this->set_size(strlen(value) + (include_null_terminator ? 1 : 0));
	}

	template<typename T>
	BitSlice(T* value):
		bits{(char*)value},
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
		this->bits = (char*)realloc(this->bits, this->size);
	}

	size_t get_size() const {
		return this->size;
	}

	bool operator[](size_t index) const {
		return this->get_bit(index);
	}

	char get_byte(size_t index) const {
		CHECK_BYTE_IN_BOUNDS;
		return this->bits[index];
	}

	void set_byte(size_t index, char value) {
		CHECK_BYTE_IN_BOUNDS;
		this->bits[index] = value;
	}

	void set_bit(size_t index, bool value) {
		CHECK_BIT_IN_BOUNDS;
		size_t byte_index = byte_index_from_bit(index);
		this->bits[byte_index] = SET_BIT(this->bits[byte_index], index, value);
	}

	bool get_bit(size_t index) const {
		CHECK_BIT_IN_BOUNDS;
		return GET_BIT(this->bits[byte_index_from_bit(index)], index);
	}

	std::string to_string(
		bool show_separator = false,
		bool reverse = false,
		bool show_decimal_values = false,
		bool show_hex_values = false
	) const {
		std::string temp_str;
		size_t bits = this->size * 8;

		for (size_t byte = 0; byte < this->size; byte++) {
			unsigned char current_byte = this->bits[reverse ? (this->size - byte - 1) : byte];

			if (show_separator)
				temp_str += '|';

			for (size_t bit = 8; bit > 0; bit--) {
				temp_str += std::to_string(GET_BIT(current_byte, bit - 1));
			}

			if (show_decimal_values)
				temp_str += std::string(":") += std::to_string(current_byte);

			if (show_hex_values)
				temp_str += std::string(":") + char_to_hex(current_byte);
		}

		return std::string("0b") += temp_str;
	}
};


class test {
private:
	unsigned char value = 120;
	unsigned char value2 = 0;
	unsigned char value3 = 50;
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
}
