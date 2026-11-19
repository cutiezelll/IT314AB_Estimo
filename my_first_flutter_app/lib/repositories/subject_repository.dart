import 'package:postgres/postgres.dart';

import '../core/db_connection.dart';
import '../models/subject.dart';

class SubjectRepository {
  Future<List<Subject>> getSubjects() async {
    final connection = await DbConnection.getConnection();

    final result = await connection.execute(
      'SELECT * FROM subjects ORDER BY subject_id ASC',
    );

    return result.map((row) {
      return Subject.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> addSubject(Subject subject) async {
    final connection = await DbConnection.getConnection();
    final data = subject.toDatabaseMap();

    await connection.execute(
      Sql.named('''
        INSERT INTO subjects (
          subject_code,
          subject_name,
          units,
          description
        )
        VALUES (
          @subject_code,
          @subject_name,
          @units,
          @description
        )
      '''),
      parameters: data,
    );
  }

  Future<void> updateSubject(Subject subject) async {
    if (subject.subjectId == null) {
      throw Exception('Subject database ID is missing.');
    }

    final connection = await DbConnection.getConnection();
    final data = subject.toDatabaseMap();

    data['subject_id'] = subject.subjectId;

    await connection.execute(
      Sql.named('''
        UPDATE subjects
        SET
          subject_code = @subject_code,
          subject_name = @subject_name,
          units = @units,
          description = @description
        WHERE subject_id = @subject_id
      '''),
      parameters: data,
    );
  }

  Future<void> deleteSubject(int subjectId) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('DELETE FROM subjects WHERE subject_id = @id'),
      parameters: {'id': subjectId},
    );
  }
}
