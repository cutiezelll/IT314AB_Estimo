import 'package:postgres/postgres.dart';

import '../core/db_connection.dart';
import '../profile.dart';

class StudentRepository {
  Future<List<Student>> getStudents() async {
    final connection = await DbConnection.getConnection();

    final result = await connection.execute(
      'SELECT * FROM students ORDER BY student_id ASC',
    );

    return result.map((row) {
      return Student.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> addStudent(Student student) async {
    final connection = await DbConnection.getConnection();
    final data = student.toDatabaseMap();

    await connection.execute(
      Sql.named('''
        INSERT INTO students (
          student_number,
          first_name,
          last_name,
          email,
          course,
          year_level,
          age,
          hobby,
          favorite_subject,
          contact_number
        )
        VALUES (
          @student_number,
          @first_name,
          @last_name,
          @email,
          @course,
          @year_level,
          @age,
          @hobby,
          @favorite_subject,
          @contact_number
        )
      '''),
      parameters: data,
    );
  }

  Future<void> updateStudent(Student student) async {
    if (student.databaseId == null) {
      throw Exception('Student database ID is missing.');
    }

    final connection = await DbConnection.getConnection();
    final data = student.toDatabaseMap();

    data['database_id'] = student.databaseId;

    await connection.execute(
      Sql.named('''
        UPDATE students
        SET
          student_number = @student_number,
          first_name = @first_name,
          last_name = @last_name,
          email = @email,
          course = @course,
          year_level = @year_level,
          age = @age,
          hobby = @hobby,
          favorite_subject = @favorite_subject,
          contact_number = @contact_number
        WHERE student_id = @database_id
      '''),
      parameters: data,
    );
  }

  Future<void> deleteStudent(int databaseId) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('DELETE FROM students WHERE student_id = @id'),
      parameters: {'id': databaseId},
    );
  }
}
