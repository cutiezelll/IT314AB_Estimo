class Schedule {
  int? scheduleId;
  int subjectId;
  String dayOfWeek;
  String startTime;
  String endTime;
  String? room;
  int slotCapacity;
  int enrolledCount;

  Schedule({
    this.scheduleId,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.slotCapacity,
    this.enrolledCount = 0,
  });

  int get availableSlots {
    final remaining = slotCapacity - enrolledCount;
    return remaining < 0 ? 0 : remaining;
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    String formatTime(dynamic value) {
      return value.toString().replaceAll(RegExp(r'^Time\(|\)$'), '');
    }

    return Schedule(
      scheduleId: map['schedule_id'] as int?,
      subjectId: map['subject_id'] as int,
      dayOfWeek: map['day_of_week'] ?? '',
      startTime: formatTime(map['start_time']),
      endTime: formatTime(map['end_time']),
      room: map['room'] as String?,
      slotCapacity: map['slot_capacity'] as int,
      enrolledCount: map['enrolled_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'subject_id': subjectId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'slot_capacity': slotCapacity,
    };
  }
}
