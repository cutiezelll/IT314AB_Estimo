import 'package:flutter/material.dart';

import '../profile.dart';
import '../repositories/student_repository.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  bool isLoading = true;
  String? loadError;

  final StudentRepository studentRepository = StudentRepository();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final fetchedStudents = await studentRepository.getStudents();

      fetchedStudents.sort((a, b) => a.name.compareTo(b.name));

      if (!mounted) return;

      setState(() {
        students = fetchedStudents;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadError = e.toString();
        isLoading = false;
      });
    }
  }

  void toggleFavorite(Student student) {
    setState(() {
      student.isFavorite = !student.isFavorite;
      student.isFavorite ? student.likeCount++ : student.likeCount--;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          student.isFavorite
              ? 'You liked this person!'
              : '${student.name} removed from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> deleteStudent(Student student) async {
    if (student.databaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student database ID is missing.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student?'),
          content: Text('Are you sure you want to delete ${student.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await studentRepository.deleteStudent(student.databaseId!);

      if (!mounted) return;

      setState(() {
        students.remove(student);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${student.name} deleted successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void openDetails(Student student) {
    Navigator.pushNamed(
      context,
      AppRoutes.studentDetails,
      arguments: student,
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> openAddStudent() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addStudent);

    if (!mounted) return;

    if (result == true) {
      await loadStudents();
    }
  }

  Widget statusIndicator(Student student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: student.active ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: student.active ? Colors.green : Colors.red),
      ),
      child: Text(
        student.active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: student.active ? Colors.green[800] : Colors.red[800],
        ),
      ),
    );
  }

  Widget loadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading students...',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Unable to load students.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              loadError ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[500]),
          const SizedBox(height: 16),
          const Text(
            'No students found.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Student directory is empty.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: openAddStudent,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  Widget profileCard(Student student) {
    return GestureDetector(
      key: ValueKey(student.studentId),
      onTap: () => openDetails(student),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        student.image,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => toggleFavorite(student),
                    icon: Icon(
                      student.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              statusIndicator(student),
              const SizedBox(height: 10),
              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${student.course} - ${student.yearLevel}'),
              const SizedBox(height: 6),
              Text('Age: ${student.age}'),
              Text('Hobby: ${student.hobby}'),
              Text('Student ID: ${student.studentId}'),
              Text('Email: ${student.email}'),
              Text('Favorite Subject: ${student.favoriteSubject}'),
              Text('Likes: ${student.likeCount}'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => openDetails(student),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => deleteStudent(student),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E3E3),
      appBar: AppBar(
        title: const Text('My First Flutter Application'),
        actions: [
          IconButton(onPressed: loadStudents, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? loadingState()
          : loadError != null
          ? errorState()
          : students.isEmpty
          ? emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return profileCard(students[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddStudent,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
