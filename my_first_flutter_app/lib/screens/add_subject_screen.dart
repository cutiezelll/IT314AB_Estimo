import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../repositories/subject_repository.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final subjectCodeController = TextEditingController();
  final subjectNameController = TextEditingController();
  final unitsController = TextEditingController();
  final descriptionController = TextEditingController();

  final SubjectRepository subjectRepository = SubjectRepository();

  bool isSubmitting = false;

  Future<void> saveSubject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final newSubject = Subject(
      subjectCode: subjectCodeController.text.trim(),
      subjectName: subjectNameController.text.trim(),
      units: int.parse(unitsController.text.trim()),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    );

    try {
      await subjectRepository.addSubject(newSubject);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject added successfully to Neon!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add subject: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    subjectCodeController.dispose();
    subjectNameController.dispose();
    unitsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subject')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.menu_book, size: 65, color: Colors.blue),
              const SizedBox(height: 12),
              const Text(
                'Subject Information',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              buildTextField(
                label: 'Subject Code',
                controller: subjectCodeController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject code';
                  }
                  return null;
                },
              ),

              buildTextField(
                label: 'Subject Name',
                controller: subjectNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),

              buildTextField(
                label: 'Units',
                controller: unitsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter units';
                  }

                  final units = int.tryParse(value.trim());

                  if (units == null || units <= 0) {
                    return 'Enter a valid number of units';
                  }

                  return null;
                },
              ),

              buildTextField(
                label: 'Description (Optional)',
                controller: descriptionController,
                maxLines: 3,
                validator: (value) => null,
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: isSubmitting ? null : saveSubject,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isSubmitting ? 'Saving...' : 'Save Subject'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
