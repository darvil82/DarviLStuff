#include <iomanip>
#include <memory.h>
#include <sstream>
#include <string>
#include <vector>

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

	// methods for getting just a byte or a bool. Used by the iterators
	byte get_byte_primitive(size_t index) const {
		binmgr__CHECK_BYTE_IN_BOUNDS;
		return this->bits[index];
	}

	bool get_bit_primitive(size_t index) {
		binmgr__CHECK_BIT_IN_BOUNDS;
		return binmgr__GET_BIT(this->bits[index / 8], index % 8);
	}


	template<class TValue> class BitSliceIterator {
	protected:
		size_t current = 0;
		BitSlice& bs;

	public:
		BitSliceIterator(BitSlice& bs, size_t index = 0) :
			bs{bs}, current{index} {}

		virtual TValue operator*() const {
			return TValue{this->bs, this->current};
		};

		void operator++() { current++; }

		bool operator!=(const BitSliceIterator& other) const {
			return this->current != other.current;
		}
	};

	// this is something that can modify the bitslice indirectly
	template<class TInnerValue> class ModifiableValueBase {
	protected:
		BitSlice& bs;
		size_t index;

	public:
		ModifiableValueBase(BitSlice& bs, size_t index) :
			bs{bs}, index{index} {}

		TInnerValue operator*() const { return this->get_value(); }
		operator TInnerValue() const { return this->get_value(); }
		size_t get_index() const { return this->index; }
		void flip() { this->operator=(~this->get_value()); }
		bool operator==(const ModifiableValueBase<TInnerValue>& other) const {
			return this->get_value() == other.get_value();
		}

		virtual TInnerValue get_value() const = 0;
		virtual TInnerValue operator=(TInnerValue new_value) const = 0;
	};


	class BitWrapper : public ModifiableValueBase<bool> {
		using ModifiableValueBase::ModifiableValueBase;

	public:
		bool get_value() const override {
			return this->bs.get_bit_primitive(index);
		}

		bool operator=(bool new_value) const override {
			this->bs.set_bit(index, new_value);
			return new_value;
		}
	};


	class ByteWrapper : public ModifiableValueBase<byte> {
		using ModifiableValueBase::ModifiableValueBase;

		// bytes should also be iterable in its 8 units range
		class ByteIterator : public BitSliceIterator<BitWrapper> {
		public:
			// we want to multiply by 8 here because we want to get the bit
			ByteIterator(BitSlice& bs, size_t index = 0) :
				BitSliceIterator{bs, index * 8} {}
		};

	public:
		byte get_value() const override {
			return this->bs.get_byte_primitive(index);
		}

		byte operator=(byte new_value) const override {
			this->bs.set_byte(index, new_value);
			return new_value;
		}

		BitWrapper operator[](size_t bit_index) const {
			if (bit_index >= 8 || bit_index < 0) {
				throw std::invalid_argument(
					"Bit index is out of bounds of the current byte");
			}
			return {this->bs, this->index * 8 + bit_index};
		}

		std::string
			to_string(bool show_decimal = false, bool show_hex = false) const {
			std::string temp_str;

			for (size_t i = 0; i < 8; i++) {
				temp_str += std::to_string((*this)[i]);
			}

			if (show_decimal)
				temp_str += std::string(":") +=
					std::to_string(this->get_value());

			if (show_hex)
				temp_str += std::string(":0x") +=
					byte_to_hex(this->get_value());

			return temp_str;
		}

		ByteIterator begin() { return ByteIterator{this->bs, this->index}; }
		ByteIterator end() { return ByteIterator{this->bs, this->index + 1}; }
	};




public:
	BitSlice() : BitSlice((byte)0) {}

	template<typename T>
	BitSlice(T value) : size{sizeof(value)}, bits{new byte[this->size]} {
		memcpy(this->bits, &value, this->size);
	}

	BitSlice(char* value, bool include_null_terminator = false) :
		bits{reinterpret_cast<byte*>(value)}, own_ptr{false} {
		this->set_size(strlen(value) + include_null_terminator);
	}

	template<typename T>
	BitSlice(T* value) : bits{reinterpret_cast<byte*>(value)}, own_ptr{false} {
		this->set_size(sizeof(*value));
	}

	BitSlice(const BitSlice& bs) :
		bits{bs.bits}, own_ptr{bs.own_ptr}, size{bs.size} {}

	~BitSlice() {
		if (this->own_ptr)
			delete this->bits;
	}

	static BitSlice from_size(size_t size) {
		BitSlice bs;
		bs.resize(size);
		return bs;
	}

	bool operator==(const BitSlice& other) const {
		if (this->size != other.size)
			return false;

		for (size_t i = 0; i < this->size; i++) {
			if (this->get_byte_primitive(i) != other.get_byte_primitive(i))
				return false;
		}

		return true;
	}

	void resize(size_t size) {
		if (!this->own_ptr) {
			throw ResizeCustomPointerError();
		}

		// if the size is the same, we don't need to do anything
		if (this->size == size)
			return;

		size_t prev_size = this->size;

		this->set_size(size);
		this->bits = static_cast<byte*>(realloc(this->bits, size));

		// if the size is bigger, we need to clear the new memory
		if (size > prev_size)
			memset(this->bits + prev_size, 0, size - prev_size);
	}

	size_t get_size() const { return this->size; }

	ByteWrapper get_byte(size_t index) {
		binmgr__CHECK_BYTE_IN_BOUNDS;
		return {*this, index};
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

	ByteWrapper operator[](size_t index) { return this->get_byte(index); }

	BitWrapper get_bit(size_t index) {
		binmgr__CHECK_BIT_IN_BOUNDS;
		return {*this, index};
	}

	void set_all(byte value) { memset(this->bits, value, this->size); }

	void flip_all() {
		for (auto x = this->begin_bytes(); x != this->end_bytes(); ++x) {
			(*x).flip();
		}
	}

	std::vector<ByteWrapper> get_bytes_in_range(size_t start, size_t end) {
		this->check_in_bounds(start, false);
		this->check_in_bounds(end, false);

		std::vector<ByteWrapper> bytes;
		for (size_t i = start; i <= end; i++) {
			bytes.push_back(this->get_byte(i));
		}
		return bytes;
	}

	std::vector<BitWrapper> get_bits_in_range(size_t start, size_t end) {
		this->check_in_bounds(start);
		this->check_in_bounds(end);

		std::vector<BitWrapper> bits;
		for (size_t i = start; i <= end; i++) {
			bits.push_back(this->get_bit(i));
		}
		return bits;
	}

	std::string to_string(
		bool reverse = false, bool show_decimal = false, bool show_hex = false,
		bool show_separator = false) {
		std::string temp_str;

		for (size_t byte_ = 0; byte_ < this->size; byte_++) {
			byte current_byte =
				this->bits[reverse ? (this->size - byte_ - 1) : byte_];

			// display a separator between bytes
			if ((show_decimal || show_hex) || show_separator) {
				temp_str += '|';
			}

			// show each bit
			temp_str += this->get_byte(byte_).to_string(show_decimal, show_hex);
		}

		return std::string("0b") += temp_str;
	}

	BitSliceIterator<BitWrapper> begin() { return {*this}; }
	BitSliceIterator<BitWrapper> end() { return {*this, this->size * 8}; }
	BitSliceIterator<ByteWrapper> begin_bytes() { return {*this}; }
	BitSliceIterator<ByteWrapper> end_bytes() { return {*this, this->size}; }
};
