import 'package:flutter/material.dart';

import '../models/enrollment.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../profile.dart';
import '../repositories/student_repository.dart';
import '../repositories/subject_repository.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/enrollment_repository.dart';
import '../repositories/grade_repository.dart';

class AddEnrollmentScreen extends StatefulWidget {
  const AddEnrollmentScreen({super.key});

  @override
  State<AddEnrollmentScreen> createState() => _AddEnrollmentScreenState();
}

class _AddEnrollmentScreenState extends State<AddEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final StudentRepository studentRepository = StudentRepository();
  final SubjectRepository subjectRepository = SubjectRepository();
  final ScheduleRepository scheduleRepository = ScheduleRepository();
  final EnrollmentRepository enrollmentRepository = EnrollmentRepository();
  final GradeRepository gradeRepository = GradeRepository();

  List<Student> students = [];
  List<Subject> subjects = [];
  List<Schedule> schedules = [];

  int? selectedStudentId;
  int? selectedSubjectId;
  int? selectedScheduleId;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final studentResult = await studentRepository.getStudents();
      final subjectResult = await subjectRepository.getSubjects();
      final scheduleResult = await scheduleRepository.getSchedules();

      if (!mounted) return;

      setState(() {
        students = studentResult;
        subjects = subjectResult;
        schedules = scheduleResult;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Schedule> get availableSchedules {
    if (selectedSubjectId == null) {
      return [];
    }

    return schedules.where((schedule) {
      return schedule.subjectId == selectedSubjectId;
    }).toList();
  }

  Future<void> saveEnrollment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedStudentId == null ||
        selectedSubjectId == null ||
        selectedScheduleId == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final grades = await gradeRepository.getGrades();

      final selectedSubject = subjects.firstWhere(
        (subject) => subject.subjectId == selectedSubjectId,
      );

      final failedGrade = grades.any((grade) {
        return grade.studentId == selectedStudentId &&
            grade.subjectCode == selectedSubject.subjectCode &&
            grade.gradeValue > 3.00 &&
            grade.gradeValue <= 5.00;
      });

      if (failedGrade) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enrollment denied. This student has a failing grade in this subject.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isSaving = false;
        });
        return;
      }

      final existingEnrollments = await enrollmentRepository.getEnrollments();

      final existingEnrollment = existingEnrollments.where((enrollment) {
        return enrollment.studentId == selectedStudentId &&
            enrollment.subjectId == selectedSubjectId;
      });

      if (existingEnrollment.isNotEmpty) {
        final existing = existingEnrollment.first;

        if (!mounted) return;

        if (existing.status == 'Dropped') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This student has a dropped enrollment for this subject. '
                'Reactivate it from the Enrollments screen first.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This student is already enrolled in this subject.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }

        setState(() {
          isSaving = false;
        });
        return;
      }

      final enrollment = Enrollment(
        studentId: selectedStudentId!,
        subjectId: selectedSubjectId!,
        scheduleId: selectedScheduleId!,
      );

      await enrollmentRepository.addEnrollment(enrollment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student enrolled successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enrollment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Enrollment')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 45,
                    ),
                    const Text('Failed to load enrollment data.'),
                    const SizedBox(height: 8),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: loadData,
                      child: const Text('Try Again'),
                    ),
                  ],
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
                      'Select Student',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedStudentId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Choose a student',
                      ),
                      items: students
                          .where((student) => student.databaseId != null)
                          .map((student) {
                            return DropdownMenuItem<int>(
                              value: student.databaseId,
                              child: Text(
                                '${student.name} (${student.studentId})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStudentId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a student.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Subject',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedSubjectId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.menu_book),
                        hintText: 'Choose a subject',
                      ),
                      items: subjects
                          .where((subject) => subject.subjectId != null)
                          .map((subject) {
                            return DropdownMenuItem<int>(
                              value: subject.subjectId,
                              child: Text(
                                '${subject.subjectCode} - ${subject.subjectName}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubjectId = value;
                          selectedScheduleId = null;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a subject.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedScheduleId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month),
                        hintText: 'Choose a schedule',
                      ),
                      items: availableSchedules
                          .where((schedule) => schedule.scheduleId != null)
                          .map((schedule) {
                            return DropdownMenuItem<int>(
                              value: schedule.scheduleId,
                              child: Text(
                                '${schedule.dayOfWeek} '
                                '${schedule.startTime} - ${schedule.endTime}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .toList(),
                      onChanged: selectedSubjectId == null
                          ? null
                          : (value) {
                              setState(() {
                                selectedScheduleId = value;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a schedule.';
                        }
                        return null;
                      },
                    ),
                    if (selectedSubjectId != null && availableSchedules.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'No schedules available for this subject.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : saveEnrollment,
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          isSaving ? 'Enrolling...' : 'Enroll Student',
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
