import 'package:flutter/material.dart';

import '../profile.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final studentIdController = TextEditingController();
  final fullNameController = TextEditingController();
  final courseController = TextEditingController();
  final yearLevelController = TextEditingController();
  final ageController = TextEditingController();
  final hobbyController = TextEditingController();
  final emailController = TextEditingController();
  final favoriteSubjectController = TextEditingController();

  final List<String> validYearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Student ID';
    }

    final exists = students.any(
      (student) =>
          student.studentId.toLowerCase() == value.trim().toLowerCase(),
    );

    if (exists) {
      return 'Student ID already exists';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Email Address';
    }

    final pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

    if (!pattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? validateYearLevel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Year Level';
    }

    if (!validYearLevels.any(
      (year) => year.toLowerCase() == value.trim().toLowerCase(),
    )) {
      return 'Enter a valid year level';
    }

    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Age';
    }

    final age = int.tryParse(value.trim());

    if (age == null || age <= 0) {
      return 'Please enter a valid age';
    }

    return null;
  }

  Widget buildInputField({
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $hint';
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF8065B5), width: 1.5),
        ),
      ),
    );
  }

  void enrollStudent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newStudent = Student(
      image: 'assets/zelon.jpg',
      name: fullNameController.text.trim(),
      course: courseController.text.trim(),
      yearLevel: yearLevelController.text.trim(),
      age: int.parse(ageController.text.trim()),
      hobby: hobbyController.text.trim(),
      studentId: studentIdController.text.trim(),
      email: emailController.text.trim(),
      favoriteSubject: favoriteSubjectController.text.trim(),
      isFavorite: false,
      likeCount: 0,
      active: true,
    );

    students.add(newStudent);

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    studentIdController.dispose();
    fullNameController.dispose();
    courseController.dispose();
    yearLevelController.dispose();
    ageController.dispose();
    hobbyController.dispose();
    emailController.dispose();
    favoriteSubjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FF),
      appBar: AppBar(
        title: const Text('Add Student', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFFFFF9FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildInputField(
                hint: 'Student ID',
                controller: studentIdController,
                validator: validateStudentId,
              ),
              const SizedBox(height: 12),

              buildInputField(
                hint: 'Full Name',
                controller: fullNameController,
              ),
              const SizedBox(height: 12),

              buildInputField(hint: 'Course', controller: courseController),
              const SizedBox(height: 12),

              buildInputField(
                hint: 'Year Level',
                controller: yearLevelController,
                validator: validateYearLevel,
              ),
              const SizedBox(height: 12),

              buildInputField(
                hint: 'Age',
                controller: ageController,
                keyboardType: TextInputType.number,
                validator: validateAge,
              ),
              const SizedBox(height: 12),

              buildInputField(hint: 'Hobby', controller: hobbyController),
              const SizedBox(height: 12),

              buildInputField(
                hint: 'Email Address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 12),

              buildInputField(
                hint: 'Favorite Subject',
                controller: favoriteSubjectController,
              ),
              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: enrollStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F0FC),
                    foregroundColor: const Color(0xFF8065B5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Enroll Student',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
