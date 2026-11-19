import 'package:postgres/postgres.dart';

import '../core/db_connection.dart';
import '../models/grade.dart';

class GradeRepository {
  Future<List<Grade>> getGrades() async {
    final connection = await DbConnection.getConnection();

    final result = await connection.execute('''
      SELECT
        g.grade_id,
        g.enrollment_id,
        g.grade_value,
        g.remarks,
        g.date_recorded,
        e.student_id,
        s.first_name,
        s.last_name,
        s.student_number,
        sub.subject_code,
        sub.subject_name
      FROM grades g
      JOIN enrollments e
        ON g.enrollment_id = e.enrollment_id
      JOIN students s
        ON e.student_id = s.student_id
      JOIN subjects sub
        ON e.subject_id = sub.subject_id
      ORDER BY g.grade_id DESC
    ''');

    return result.map((row) {
      return Grade.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> addGrade(Grade grade) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        INSERT INTO grades (
          enrollment_id,
          grade_value,
          remarks,
          date_recorded
        )
        VALUES (
          @enrollment_id,
          @grade_value,
          @remarks,
          @date_recorded
        )
      '''),
      parameters: {
        'enrollment_id': grade.enrollmentId,
        'grade_value': grade.gradeValue,
        'remarks': grade.remarks,
        'date_recorded': grade.dateRecorded == null
            ? null
            : DateTime(
                grade.dateRecorded!.year,
                grade.dateRecorded!.month,
                grade.dateRecorded!.day,
              ),
      },
    );
  }

  Future<void> updateGrade(Grade grade) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        UPDATE grades
        SET
          enrollment_id = @enrollment_id,
          grade_value = @grade_value,
          remarks = @remarks,
          date_recorded = @date_recorded
        WHERE grade_id = @grade_id
      '''),
      parameters: {
        'enrollment_id': grade.enrollmentId,
        'grade_value': grade.gradeValue,
        'remarks': grade.remarks,
        'date_recorded': grade.dateRecorded == null
            ? null
            : DateTime(
                grade.dateRecorded!.year,
                grade.dateRecorded!.month,
                grade.dateRecorded!.day,
              ),
        'grade_id': grade.gradeId,
      },
    );
  }

  Future<void> deleteGrade(int gradeId) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        DELETE FROM grades
        WHERE grade_id = @grade_id
      '''),
      parameters: {'grade_id': gradeId},
    );
  }
}
