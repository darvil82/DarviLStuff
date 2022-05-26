import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class Teacher extends Person {
	private float salary;
	private byte seniority;

	Teacher(String id, String name, String surname, float salary, byte seniority) {
		super(id, name, surname, true);

		this.setSalary(salary);
		this.seniority = seniority;
	}

	Teacher(String id, String name, String surname) {
		super(id, name, surname, true);
		this.salary = -1;
		this.seniority = -1;
	}

	public static ArrayList<Teacher> loadTeachers(String file) throws IOException {
		var teachers = new ArrayList<Teacher>();

		try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"))) {
			String line;
			while ((line = br.readLine()) != null) {
				String[] values = line.split(",");
				teachers.add(new Teacher(
					values[0],
					values[1],
					values[2],
					Float.parseFloat(values[3]),
					Byte.parseByte(values[4])
				));
			}
		}

		System.out.println(teachers.size() + " loaded teachers.");

		return teachers;
	}

	public String toString() {
		return "Teacher [" + super.toString() + ", salary=" + salary + ", seniority=" + seniority + "]";
	}

	// -------------- getters and setters --------------

	public float getSueldo() {
		return salary;
	}

	public void setSalary(float salary) {
		if (salary < 50 || salary > 60000) {
			this.salary = -1;
			System.out.println("Salaries must be between 50 and 60000.");
			return;
		}

		this.salary = salary;
	}

	public byte getSeniority() {
		return seniority;
	}

	public void setSeniority(byte seniority) {
		this.seniority = seniority;
	}
}
