import 'package:flutter/material.dart';

import 'profile.dart';
import 'screens/student_list_screen.dart';
import 'screens/student_details_screen.dart';
import 'screens/add_student_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Directory',
      initialRoute: AppRoutes.studentList,
      routes: {
        AppRoutes.studentList: (context) => const StudentListScreen(),
        AppRoutes.studentDetails: (context) => const StudentDetailsScreen(),
        AppRoutes.addStudent: (context) => const AddStudentScreen(),
      },
    );
  }
}
