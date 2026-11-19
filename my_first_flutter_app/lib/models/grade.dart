class Grade {
  int? gradeId;
  int enrollmentId;
  double gradeValue;
  String? remarks;
  DateTime? dateRecorded;

  int studentId;
  String studentName;
  String studentNumber;
  String subjectCode;
  String subjectName;

  Grade({
    this.gradeId,
    required this.enrollmentId,
    required this.gradeValue,
    this.remarks,
    this.dateRecorded,
    this.studentId = 0,
    this.studentName = '',
    this.studentNumber = '',
    this.subjectCode = '',
    this.subjectName = '',
  });

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      gradeId: map['grade_id'] as int?,
      enrollmentId: map['enrollment_id'] as int,
      gradeValue: double.parse(map['grade_value'].toString()),
      remarks: map['remarks']?.toString(),
      dateRecorded: map['date_recorded'] == null
          ? null
          : DateTime.parse(map['date_recorded'].toString()),
      studentId: map['student_id'] as int? ?? 0,
      studentName: '${map['first_name'] ?? ''} ${map['last_name'] ?? ''}'
          .trim(),
      studentNumber: map['student_number']?.toString() ?? '',
      subjectCode: map['subject_code']?.toString() ?? '',
      subjectName: map['subject_name']?.toString() ?? '',
    );
  }
}
