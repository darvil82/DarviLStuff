#include <iomanip>
#include <memory.h>
#include <sstream>
#include <string>

#define binmgr__GET_BIT(value, index) (value >> index) & 1UL
#define binmgr__SET_BIT(value, index, new_bit_value)                           \
	(value & ~(1UL << index)) | (new_bit_value << index)

typedef unsigned char byte;

std::string byte_to_hex(byte data) {
	std::stringstream ss;
	ss << std::hex << std::setw(2) << std::setfill('0')
	   << static_cast<int>(data);
	return ss.str();
}

struct ResizeCustomPointerError : std::exception {
	const char* what() const noexcept override {
		return "Cannot resize custom pointer";
	}
};



class BitSlice {
#define binmgr__CHECK_BYTE_IN_BOUNDS this->check_in_bounds(index, false)
#define binmgr__CHECK_BIT_IN_BOUNDS	 this->check_in_bounds(index)

	bool own_ptr = true; // do we own the pointer to the bits?
	size_t size;		 // the size in bytes
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



	class Bit;

	class BitIterator {
		size_t current = 0;
		BitSlice& bs;

	public:
		BitIterator(BitSlice& bs, size_t index = 0) : bs{bs}, current{index} {}

		Bit operator*() const { return {bs, current}; }

		void operator++() { current++; }

		bool operator!=(BitIterator& bi) const {
			return this->current != bi.current;
		}
	};


	class Bit {
		BitSlice& bs;
		const size_t index;

	public:
		Bit(BitSlice& bs, size_t index) : bs{bs}, index{index} {}

		bool operator=(bool new_value) const {
			bs.set_bit(this->index, new_value);
			return new_value;
		}

		bool operator*() const { return this->get_value(); }

		operator bool() const { return this->get_value(); }

		size_t get_index() const { return this->index; }

		bool get_value() const { return bs.get_bit(this->index); }
	};



public:
	BitSlice() : BitSlice((byte)0) {
	}

	template<typename T>
	BitSlice(T value) : size{sizeof(value)}, bits{new byte[this->size]} {
		memcpy(this->bits, &value, this->size);
	}

	BitSlice(const char* value, bool include_null_terminator = false)
		: bits{(byte*)value}, own_ptr{false} {
		this->set_size(strlen(value) + include_null_terminator);
	}

	template<typename T>
	BitSlice(T* value) : bits{(byte*)value}, own_ptr{false} {
		this->set_size(sizeof(*value));
	}



	BitSlice(const BitSlice& bs)
		: bits{bs.bits}, own_ptr{bs.own_ptr}, size{bs.size} {
	}

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

	byte get_byte(size_t index) const {
		binmgr__CHECK_BYTE_IN_BOUNDS;
		return this->bits[index];
	}

	void set_byte(size_t index, byte value) {
		binmgr__CHECK_BYTE_IN_BOUNDS;
		this->bits[index] = value;
	}

	void set_bit(size_t index, bool value) {
		binmgr__CHECK_BIT_IN_BOUNDS;
		size_t byte_index = index / 8;
		this->bits[byte_index] =
			binmgr__SET_BIT(this->bits[byte_index], index % 8, value);
	}

	Bit operator[](size_t index) {
		return {*this, index};
	}

	bool get_bit(size_t index) {
		binmgr__CHECK_BIT_IN_BOUNDS;
		return binmgr__GET_BIT(this->bits[index / 8], index % 8);
	}

	std::string to_string(
		bool show_separator = false, bool reverse = false,
		bool show_decimal_values = false, bool show_hex_values = false) const {
		std::string temp_str;

		for (size_t byte_ = 0; byte_ < this->size; byte_++) {
			byte current_byte =
				this->bits[reverse ? (this->size - byte_ - 1) : byte_];

			// display a separator between bytes
			if (show_separator)
				temp_str += '|';

			// show each bit
			for (size_t bit = 8; bit > 0; bit--) {
				temp_str +=
					std::to_string(binmgr__GET_BIT(current_byte, bit - 1));
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
