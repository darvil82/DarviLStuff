import java.util.ArrayList;
import java.util.List;

public class App {
    public static void main(String[] args) throws Exception {
        ArrayList<Student> students = Student.loadStudents("students.txt");

        System.out.println("Student list:");
        for (Student student : students) {
            System.out.println(student);
        }

        System.out.println();

        ArrayList<Teacher> teachers = Teacher.loadTeachers("teachers.txt");

        System.out.println("Teachers list:");
        for (Teacher teacher : teachers) {
            System.out.println(teacher);
        }

        List<Student> sortedStudents = students.stream()
                .sorted((a1, a2) -> (a1.getName() + a1.getSurname()).compareTo(a2.getName() + a2.getSurname()))
                .toList();

        System.out.println("\nOrdered students:");
        for (Student student : sortedStudents) {
            System.out.println(student);
        }

        System.out.println("\nSql test:");
        System.out.println(Student.studentsToMySql(students));
    }
}
