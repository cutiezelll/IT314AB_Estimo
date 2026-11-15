class Student {
  String image;
  String name;
  String course;
  String yearLevel;
  int age;
  String hobby;
  String studentId;
  String email;
  String favoriteSubject;
  bool isFavorite;
  int likeCount;
  bool active;

  Student({
    required this.image,
    required this.name,
    required this.course,
    required this.yearLevel,
    required this.age,
    required this.hobby,
    required this.studentId,
    required this.email,
    required this.favoriteSubject,
    this.isFavorite = false,
    this.likeCount = 0,
    this.active = true,
  });
}

List<Student> students = [];
class AppRoutes {
  static const String studentList = '/';
  static const String studentDetails = '/student-details';
  static const String addStudent = '/add-student';
}