import 'package:flutter/material.dart';

import 'profile.dart';
import 'screens/student_list_screen.dart';
import 'screens/student_details_screen.dart';
import 'screens/add_student_screen.dart';
import 'screens/subject_list_screen.dart';
import 'screens/schedule_list_screen.dart';
import 'screens/enrollment_list_screen.dart';
import 'screens/grade_list_screen.dart';
import 'core/db_connection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final connection = await DbConnection.getConnection();

    final result = await connection.execute(
      'SELECT current_database(), current_user',
    );

    print('DATABASE CONNECTION SUCCESSFUL!');
    print(result);
  } catch (e) {
    print('DATABASE CONNECTION FAILED!');
    print(e);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Directory',
      home: const MainNavigationScreen(),
      routes: {
        AppRoutes.studentDetails: (context) => const StudentDetailsScreen(),
        AppRoutes.addStudent: (context) => const AddStudentScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final GlobalKey<ScheduleListScreenState> scheduleKey =
      GlobalKey<ScheduleListScreenState>();

  final List<Widget> screens = [];

  @override
  void initState() {
    super.initState();

    screens.addAll([
      const StudentListScreen(),
      const SubjectListScreen(),
      ScheduleListScreen(key: scheduleKey),
      const EnrollmentListScreen(),
      const GradeListScreen(),
    ]);
  }

  void changeTab(int index) {
    if (index == selectedIndex) return;

    setState(() {
      selectedIndex = index;
    });

    if (index == 2) {
      scheduleKey.currentState?.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: changeTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Subjects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Enrollments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Grades'),
        ],
      ),
    );
  }
}
