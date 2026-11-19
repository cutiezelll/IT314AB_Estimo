import 'package:flutter/material.dart';

import '../profile.dart';
import '../repositories/student_repository.dart';

class StudentDetailsScreen extends StatefulWidget {
  const StudentDetailsScreen({super.key});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final studentRepository = StudentRepository();

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void showEditDialog(Student student) {
    final nameController = TextEditingController(text: student.name);
    final courseController = TextEditingController(text: student.course);
    final yearController = TextEditingController(text: student.yearLevel);
    final ageController = TextEditingController(text: student.age.toString());
    final hobbyController = TextEditingController(text: student.hobby);
    final emailController = TextEditingController(text: student.email);
    final subjectController = TextEditingController(
      text: student.favoriteSubject,
    );

    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit ${student.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: courseController,
                      decoration: const InputDecoration(labelText: 'Course'),
                    ),
                    TextField(
                      controller: yearController,
                      decoration: const InputDecoration(
                        labelText: 'Year Level',
                      ),
                    ),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'),
                    ),
                    TextField(
                      controller: hobbyController,
                      decoration: const InputDecoration(labelText: 'Hobby'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Favorite Subject',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newAge = int.tryParse(ageController.text);

                          if (nameController.text.trim().isEmpty ||
                              newAge == null ||
                              newAge < 0) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid name and age.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          student.name = nameController.text.trim();
                          student.course = courseController.text.trim();
                          student.yearLevel = yearController.text.trim();
                          student.age = newAge;
                          student.hobby = hobbyController.text.trim();
                          student.email = emailController.text.trim();
                          student.favoriteSubject = subjectController.text
                              .trim();

                          try {
                            await studentRepository.updateStudent(student);

                            if (!mounted) return;

                            setState(() {});

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Student updated successfully in Neon!',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Update failed: $error')),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      courseController.dispose();
      yearController.dispose();
      ageController.dispose();
      hobbyController.dispose();
      emailController.dispose();
      subjectController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        actions: [
          IconButton(
            onPressed: () => showEditDialog(student),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Student',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              student.image,
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 80),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              student.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    detailRow('Student ID', student.studentId),
                    detailRow('Course', student.course),
                    detailRow('Year Level', student.yearLevel),
                    detailRow('Status', student.active ? 'Active' : 'Inactive'),
                    detailRow('Age', student.age.toString()),
                    detailRow('Hobby', student.hobby),
                    detailRow('Email', student.email),
                    detailRow('Favorite Subject', student.favoriteSubject),
                    detailRow('Likes', student.likeCount.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => showEditDialog(student),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Student'),
            ),
          ],
        ),
      ),
    );
  }
}
