import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;

public class Student extends Person {
	private String course;
	private int classroom;

	Student(String id, String name, String surname, String course, int classroom) {
		super(id, name, surname, true);
		this.course = course;
		this.classroom = classroom;
	}

	Student(String id, String name, String surname) {
		super(id, name, surname, true);
		this.course = "";
		this.classroom = -1;
	}

	public static ArrayList<Student> loadStudents(String file) throws IOException {
		var students = new ArrayList<Student>();

		try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"))) {
			String line;
			while ((line = br.readLine()) != null) {
				String[] values = line.split(",");
				students.add(new Student(
					values[0],
					values[1],
					values[2],
					values[3],
					Integer.parseInt(values[4])
				));
			}
		}

		System.out.println(students.size() + " loaded students.");

		return students;
	}

	public String toString() {
		return "Student [" + super.toString() + ", course=" + course + ", classroom=" + classroom + "]";
	}

	public String toMySql() {
		return "INSERT INTO alumnos VALUES ('" + this.id + "', '" + this.name + "', '" + this.surname + "', '"
				+ this.course + "', " + this.classroom + ");";
	}

	public static String studentsToMySql(Collection<Student> students) {
		return String.join("\n", students.stream().map(a -> a.toMySql()).toList());
	}

	// -------------- getters and setters --------------

	public String getCourse() {
		return course;
	}

	public void setCourse(String course) {
		this.course = course;
	}

	public int getClassroom() {
		return classroom;
	}

	public void setClassroom(int classroom) {
		this.classroom = classroom;
	}
}
