import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../repositories/subject_repository.dart';
import 'add_subject_screen.dart';
import 'edit_subject_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final SubjectRepository subjectRepository = SubjectRepository();

  List<Subject> subjects = [];
  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final result = await subjectRepository.getSubjects();

      if (!mounted) return;

      setState(() {
        subjects = result;
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

  Future<void> openAddSubject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSubjectScreen()),
    );

    if (result == true) {
      await loadSubjects();
    }
  }

  Future<void> openEditSubject(Subject subject) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSubjectScreen(subject: subject),
      ),
    );

    if (result == true) {
      await loadSubjects();
    }
  }

  Future<void> deleteSubject(Subject subject) async {
    if (subject.subjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subject ID is missing.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete ${subject.subjectCode}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await subjectRepository.deleteSubject(subject.subjectId!);

      if (!mounted) return;

      setState(() {
        subjects.removeWhere((item) => item.subjectId == subject.subjectId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subject deleted successfully from Neon!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget subjectCard(Subject subject) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, size: 30, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject.subjectCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(label: Text('${subject.units} Units')),
                IconButton(
                  onPressed: () => openEditSubject(subject),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit Subject',
                ),
                IconButton(
                  onPressed: () => deleteSubject(subject),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Subject',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subject.subjectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subject.description?.isNotEmpty == true
                  ? subject.description!
                  : 'No description available.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(onPressed: loadSubjects, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
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
                    const SizedBox(height: 10),
                    const Text('Failed to load subjects.'),
                    const SizedBox(height: 8),
                    Text(loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: loadSubjects,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : subjects.isEmpty
          ? RefreshIndicator(
              onRefresh: loadSubjects,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('No subjects found in the database.')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadSubjects,
              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return subjectCard(subjects[index]);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddSubject,
        child: const Icon(Icons.add),
      ),
    );
  }
}
