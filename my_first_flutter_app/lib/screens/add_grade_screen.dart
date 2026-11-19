import 'package:flutter/material.dart';

import '../models/enrollment.dart';
import '../models/grade.dart';
import '../repositories/enrollment_repository.dart';
import '../viewmodels/grade_viewmodel.dart';

class AddGradeScreen extends StatefulWidget {
  const AddGradeScreen({super.key});

  @override
  State<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  final _formKey = GlobalKey<FormState>();

  final EnrollmentRepository enrollmentRepository = EnrollmentRepository();

  final GradeViewModel gradeViewModel = GradeViewModel();

  final gradeController = TextEditingController();
  final remarksController = TextEditingController();

  List<Enrollment> enrollments = [];

  int? selectedEnrollmentId;
  DateTime selectedDate = DateTime.now();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadEnrollments();
  }

  Future<void> loadEnrollments() async {
    try {
      final result = await enrollmentRepository.getEnrollments();

      if (!mounted) return;

      setState(() {
        enrollments = result
            .where((enrollment) => enrollment.status == 'Enrolled')
            .toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load enrollments: $e')));
    }
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> saveGrade() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedEnrollmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an enrollment.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final grade = Grade(
      enrollmentId: selectedEnrollmentId!,
      gradeValue: double.parse(gradeController.text.trim()),
      remarks: remarksController.text.trim().isEmpty
          ? null
          : remarksController.text.trim(),
      dateRecorded: selectedDate,
    );

    final success = await gradeViewModel.addGrade(grade);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grade added successfully!')),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(gradeViewModel.errorMessage ?? 'Failed to add grade.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    gradeController.dispose();
    remarksController.dispose();
    gradeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Grade'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : enrollments.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No active enrollments available. '
                  'Please enroll a student first.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Enrollment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: selectedEnrollmentId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select student and subject',
                      ),
                      items: enrollments.map((enrollment) {
                        return DropdownMenuItem<int>(
                          value: enrollment.enrollmentId,
                          child: Text(
                            '${enrollment.studentName} - '
                            '${enrollment.subjectCode}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEnrollmentId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an enrollment.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Grade Value',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: gradeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter grade (1.00 - 5.00)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a grade.';
                        }

                        final grade = double.tryParse(value.trim());

                        if (grade == null || !grade.isFinite) {
                          return 'Please enter a valid number.';
                        }

                        if (grade < 1.0 || grade > 5.0) {
                          return 'Grade must be between 1.00 and 5.00.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Remarks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: remarksController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter remarks (optional)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Date Recorded',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                        child: Text(
                          '${selectedDate.year}-'
                          '${selectedDate.month.toString().padLeft(2, '0')}-'
                          '${selectedDate.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveGrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save Grade'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
