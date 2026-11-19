import 'package:postgres/postgres.dart';

import '../core/db_connection.dart';
import '../models/enrollment.dart';

class EnrollmentRepository {
  Future<List<Enrollment>> getEnrollments() async {
    final connection = await DbConnection.getConnection();

    final result = await connection.execute('''
      SELECT
        e.enrollment_id,
        e.student_id,
        e.subject_id,
        e.schedule_id,
        e.enrolled_at,
        e.status,
        s.first_name,
        s.last_name,
        s.student_number,
        sub.subject_code,
        sub.subject_name,
        sch.day_of_week,
        sch.start_time,
        sch.end_time,
        sch.room,
        sch.slot_capacity,
        (
          SELECT COUNT(*)
          FROM enrollments active
          WHERE active.schedule_id = e.schedule_id
          AND active.status = 'Enrolled'
        ) AS enrolled_count
      FROM enrollments e
      JOIN students s ON e.student_id = s.student_id
      JOIN subjects sub ON e.subject_id = sub.subject_id
      JOIN schedules sch ON e.schedule_id = sch.schedule_id
      ORDER BY e.enrollment_id DESC
    ''');

    return result.map((row) {
      return Enrollment.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> addEnrollment(Enrollment enrollment) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        INSERT INTO enrollments (
          student_id,
          subject_id,
          schedule_id
        )
        VALUES (
          @student_id,
          @subject_id,
          @schedule_id
        )
      '''),
      parameters: {
        'student_id': enrollment.studentId,
        'subject_id': enrollment.subjectId,
        'schedule_id': enrollment.scheduleId,
      },
    );
  }

  Future<void> dropEnrollment(int enrollmentId) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        UPDATE enrollments
        SET status = @status
        WHERE enrollment_id = @id
      '''),
      parameters: {'status': 'Dropped', 'id': enrollmentId},
    );
  }

  Future<void> reactivateEnrollment(int enrollmentId) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        UPDATE enrollments
        SET status = @status
        WHERE enrollment_id = @id
      '''),
      parameters: {'status': 'Enrolled', 'id': enrollmentId},
    );
  }
}
