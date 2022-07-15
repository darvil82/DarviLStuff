#include <vector>
#include <functional>
#include <iostream>


template<class T>
class EventHandler {
	typedef std::function<void(T&)> callback_t;
	std::vector<callback_t> callbacks;

public:
	void operator+=(const callback_t& callback) {
		callbacks.push_back(callback);
	}

	void invoke(T& value) const {
		for (const callback_t& func : callbacks)
			func(value);
	}
};


struct Result {
	bool state;
	std::string info;

	Result(bool state, std::string info):
		state{state}, info{info}
	{}
};

void show_state(Result& res) {
	std::cout << res.state << std::endl;
}


int main() {
	EventHandler<Result&> eh;

	eh += show_state;
	eh += [](const Result& b) {
		std::cout << b.info << std::endl;
	};

	Result myResult(true, "holy poggers");

	eh.invoke(myResult);
}