class Enrollment {
  int? enrollmentId;
  int studentId;
  int subjectId;
  int scheduleId;
  String? enrolledAt;
  String status;

  String studentName;
  String studentNumber;
  String subjectCode;
  String subjectName;
  String dayOfWeek;
  String startTime;
  String endTime;
  String? room;

  int slotCapacity;
  int enrolledCount;

  Enrollment({
    this.enrollmentId,
    required this.studentId,
    required this.subjectId,
    required this.scheduleId,
    this.enrolledAt,
    this.status = 'Enrolled',
    this.studentName = '',
    this.studentNumber = '',
    this.subjectCode = '',
    this.subjectName = '',
    this.dayOfWeek = '',
    this.startTime = '',
    this.endTime = '',
    this.room,
    this.slotCapacity = 0,
    this.enrolledCount = 0,
  });

  int get availableSlots {
    final remaining = slotCapacity - enrolledCount;
    return remaining < 0 ? 0 : remaining;
  }

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    String formatTime(dynamic value) {
      return value.toString().replaceAll(RegExp(r'^Time\(|\)$'), '');
    }

    return Enrollment(
      enrollmentId: map['enrollment_id'] as int?,
      studentId: map['student_id'] as int,
      subjectId: map['subject_id'] as int,
      scheduleId: map['schedule_id'] as int,
      enrolledAt: map['enrolled_at']?.toString(),
      status: map['status']?.toString() ?? 'Enrolled',
      studentName: '${map['first_name'] ?? ''} ${map['last_name'] ?? ''}'
          .trim(),
      studentNumber: map['student_number']?.toString() ?? '',
      subjectCode: map['subject_code']?.toString() ?? '',
      subjectName: map['subject_name']?.toString() ?? '',
      dayOfWeek: map['day_of_week']?.toString() ?? '',
      startTime: formatTime(map['start_time']),
      endTime: formatTime(map['end_time']),
      room: map['room']?.toString(),
      slotCapacity: map['slot_capacity'] as int? ?? 0,
      enrolledCount: map['enrolled_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'student_id': studentId,
      'subject_id': subjectId,
      'schedule_id': scheduleId,
      'status': status,
    };
  }
}
