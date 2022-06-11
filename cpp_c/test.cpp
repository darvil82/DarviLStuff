#include <string>
#include <iostream>

#define string std::string
#define byte char
#define cout std::cout


class Person {
	string name;
	string surname;
	byte age;

	public:
		Person(string name, string surname, byte age):
			name(name),
			surname(surname),
			age(age)
		{}

		void salute() const {
			cout << "Hello, my name is " << name << " " << surname
			<< ", and I'm " << unsigned(age) << " yo!\n";
		}

		void birthday() {
			age++;
		}

		void operator<<(Person p) {
			cout << p.name << " is saying hi to " << name << ".\n";
		}
};

class Student : public Person {
	public:
		Student(string name, string surname, byte age):
			Person(name, surname, age)
		{}

		void stude() {
			cout << "I am studying\n";
		}
};


int main(int argc, char** argv) {
	Person ppl[] = {
		Person("Michael", "Jadon", 18),
		Student("Josh", "Johanson", 19)
	};

	for (Person &p : ppl) {
		p.salute();
		p.birthday();
	}


	ppl[0] << ppl[1];
}