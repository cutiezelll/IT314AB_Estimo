class Student {
  int? databaseId;
  String image;
  String name;
  String course;
  String yearLevel;
  int age;
  String hobby;
  String studentId;
  String email;
  String favoriteSubject;
  String? contactNumber;
  bool isFavorite;
  int likeCount;
  bool active;

  Student({
    this.databaseId,
    required this.image,
    required this.name,
    required this.course,
    required this.yearLevel,
    required this.age,
    required this.hobby,
    required this.studentId,
    required this.email,
    required this.favoriteSubject,
    this.contactNumber,
    this.isFavorite = false,
    this.likeCount = 0,
    this.active = true,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    final firstName = (map['first_name'] ?? '').toString().toLowerCase();

    String studentImage;

    switch (firstName) {
      case 'zel':
        studentImage = 'assets/zel.jpg';
        break;
      case 'ryan':
        studentImage = 'assets/ryan.jpg';
        break;
      case 'leon':
        studentImage = 'assets/leon.jpg';
        break;
      case 'julie':
        studentImage = 'assets/julie.jpg';
        break;
      case 'jackie':
        studentImage = 'assets/jackie.jpg';
        break;
      default:
        studentImage = 'assets/default.jpg';
    }

    return Student(
      databaseId: map['student_id'] as int?,
      image: studentImage,
      name: '${map['first_name']} ${map['last_name']}',
      course: map['course'] ?? '',
      yearLevel: map['year_level'] ?? '',
      age: (map['age'] as int?) ?? 0,
      hobby: map['hobby'] ?? '',
      studentId: map['student_number'] ?? '',
      email: map['email'] ?? '',
      favoriteSubject: map['favorite_subject'] ?? '',
      contactNumber: map['contact_number'] as String?,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    final nameParts = name.trim().split(RegExp(r'\s+'));

    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    return {
      'student_number': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'course': course,
      'year_level': yearLevel,
      'age': age,
      'hobby': hobby,
      'favorite_subject': favoriteSubject,
      'contact_number': contactNumber,
    };
  }
}

List<Student> students = [];

class AppRoutes {
  static const String studentList = '/';
  static const String studentDetails = '/student-details';
  static const String addStudent = '/add-student';
}
