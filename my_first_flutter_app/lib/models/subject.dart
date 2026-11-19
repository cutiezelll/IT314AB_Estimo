class Subject {
  int? subjectId;
  String subjectCode;
  String subjectName;
  int units;
  String? description;

  Subject({
    this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.units,
    this.description,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      subjectId: map['subject_id'] as int?,
      subjectCode: map['subject_code'] ?? '',
      subjectName: map['subject_name'] ?? '',
      units: map['units'] as int? ?? 0,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'units': units,
      'description': description,
    };
  }
}
