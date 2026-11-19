import 'package:flutter/material.dart';

import '../models/grade.dart';
import '../viewmodels/grade_viewmodel.dart';
import 'add_grade_screen.dart';
import 'edit_grade_screen.dart';

class GradeListScreen extends StatefulWidget {
  const GradeListScreen({super.key});

  @override
  State<GradeListScreen> createState() => GradeListScreenState();
}

class GradeListScreenState extends State<GradeListScreen> {
  final GradeViewModel viewModel = GradeViewModel();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await viewModel.loadGrades();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> openAddGrade() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGradeScreen()),
    );

    if (result == true) {
      await loadData();
    }
  }

  Future<void> editGrade(Grade grade) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGradeScreen(grade: grade)),
    );

    if (result == true) {
      await loadData();
    }
  }

  Future<void> deleteGrade(Grade grade) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: const Text('Are you sure you want to delete this grade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || grade.gradeId == null) return;

    final success = await viewModel.deleteGrade(grade.gradeId!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Grade deleted successfully!'
              : viewModel.errorMessage ?? 'Failed to delete grade.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          if (viewModel.isLoading && viewModel.grades.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.grades.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (viewModel.grades.isEmpty) {
            return const Center(
              child: Text(
                'No grades recorded yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.grades.length,
              itemBuilder: (context, index) {
                final grade = viewModel.grades[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Icon(Icons.grade, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    grade.studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(grade.studentNumber),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  editGrade(grade);
                                } else if (value == 'delete') {
                                  deleteGrade(grade);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 10),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          '${grade.subjectCode} - ${grade.subjectName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grade'),
                            Text(
                              grade.gradeValue.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Remarks: ${grade.remarks ?? 'No remarks'}'),
                        const SizedBox(height: 6),
                        Text(
                          'Date Recorded: ${grade.dateRecorded == null ? 'Not specified' : '${grade.dateRecorded!.year}-${grade.dateRecorded!.month.toString().padLeft(2, '0')}-${grade.dateRecorded!.day.toString().padLeft(2, '0')}'}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddGrade,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
