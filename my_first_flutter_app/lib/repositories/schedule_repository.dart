import 'package:postgres/postgres.dart';

import '../core/db_connection.dart';
import '../models/schedule.dart';

class ScheduleRepository {
  Future<List<Schedule>> getSchedules() async {
    final connection = await DbConnection.getConnection();

    final result = await connection.execute('''
      SELECT
        sch.*,
        COUNT(e.enrollment_id) FILTER (
          WHERE e.status = 'Enrolled'
        ) AS enrolled_count
      FROM schedules sch
      LEFT JOIN enrollments e
        ON sch.schedule_id = e.schedule_id
      GROUP BY sch.schedule_id
      ORDER BY sch.schedule_id ASC
    ''');

    return result.map((row) {
      return Schedule.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        INSERT INTO schedules (
          subject_id,
          day_of_week,
          start_time,
          end_time,
          room,
          slot_capacity
        )
        VALUES (
          @subject_id,
          @day_of_week,
          @start_time,
          @end_time,
          @room,
          @slot_capacity
        )
      '''),
      parameters: {
        'subject_id': schedule.subjectId,
        'day_of_week': schedule.dayOfWeek,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'room': schedule.room,
        'slot_capacity': schedule.slotCapacity,
      },
    );
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        UPDATE schedules
        SET
          subject_id = @subject_id,
          day_of_week = @day_of_week,
          start_time = @start_time,
          end_time = @end_time,
          room = @room,
          slot_capacity = @slot_capacity
        WHERE schedule_id = @schedule_id
      '''),
      parameters: {
        'subject_id': schedule.subjectId,
        'day_of_week': schedule.dayOfWeek,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'room': schedule.room,
        'slot_capacity': schedule.slotCapacity,
        'schedule_id': schedule.scheduleId,
      },
    );
  }

  Future<void> deleteSchedule(int scheduleId) async {
    final connection = await DbConnection.getConnection();

    await connection.execute(
      Sql.named('''
        DELETE FROM schedules
        WHERE schedule_id = @schedule_id
      '''),
      parameters: {'schedule_id': scheduleId},
    );
  }
}
