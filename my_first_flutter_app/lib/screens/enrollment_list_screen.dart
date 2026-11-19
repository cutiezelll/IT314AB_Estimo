import 'package:flutter/material.dart';

import '../models/enrollment.dart';
import '../viewmodels/enrollment_viewmodel.dart';
import 'add_enrollment_screen.dart';

class EnrollmentListScreen extends StatefulWidget {
  const EnrollmentListScreen({super.key});

  @override
  State<EnrollmentListScreen> createState() => _EnrollmentListScreenState();
}

class _EnrollmentListScreenState extends State<EnrollmentListScreen> {
  final EnrollmentViewModel viewModel = EnrollmentViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadEnrollments();
  }

  Future<void> openAddEnrollment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEnrollmentScreen()),
    );

    if (result == true) {
      await viewModel.loadEnrollments();
    }
  }

  Future<void> changeEnrollmentStatus(Enrollment enrollment) async {
    if (enrollment.enrollmentId == null) return;

    final isEnrolled = enrollment.status == 'Enrolled';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEnrolled ? 'Drop Enrollment' : 'Reactivate Enrollment'),
        content: Text(
          isEnrolled
              ? 'Are you sure you want to drop this enrollment?'
              : 'Are you sure you want to reactivate this enrollment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isEnrolled ? 'Drop' : 'Reactivate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = isEnrolled
        ? await viewModel.dropEnrollment(enrollment.enrollmentId!)
        : await viewModel.reactivateEnrollment(enrollment.enrollmentId!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? isEnrolled
                    ? 'Enrollment dropped successfully!'
                    : 'Enrollment reactivated successfully!'
              : 'Operation failed: ${viewModel.errorMessage}',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget enrollmentCard(Enrollment enrollment) {
    final isEnrolled = enrollment.status == 'Enrolled';
    final available = enrollment.availableSlots;
    final isFull = available == 0;
    final progress = enrollment.slotCapacity > 0
        ? (enrollment.enrolledCount / enrollment.slotCapacity).clamp(0.0, 1.0)
        : 0.0;

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
                const Icon(Icons.school, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    enrollment.studentName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'status') {
                      changeEnrollmentStatus(enrollment);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'status',
                      child: Text(
                        isEnrolled ? 'Drop Enrollment' : 'Reactivate',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Student No.: ${enrollment.studentNumber}'),
            const Divider(height: 24),
            Text(
              '${enrollment.subjectCode} - ${enrollment.subjectName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            detailRow(Icons.calendar_today, enrollment.dayOfWeek),
            detailRow(
              Icons.access_time,
              '${enrollment.startTime} - ${enrollment.endTime}',
            ),
            detailRow(
              Icons.room,
              enrollment.room?.isNotEmpty == true
                  ? enrollment.room!
                  : 'No room assigned',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFull ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Capacity: ${enrollment.slotCapacity}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Enrolled Students: ${enrollment.enrolledCount}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Available Slots: $available',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isFull ? Colors.red : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    color: isFull ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isFull ? 'No available slots' : 'Slots are available',
                    style: TextStyle(
                      color: isFull ? Colors.red : Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(enrollment.status),
                  backgroundColor: isEnrolled
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  labelStyle: TextStyle(
                    color: isEnrolled
                        ? Colors.green.shade900
                        : Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 19, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
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
        title: const Text('Enrollments'),
        actions: [
          IconButton(
            onPressed: viewModel.loadEnrollments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
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
                    const Text('Failed to load enrollments.'),
                    const SizedBox(height: 8),
                    Text(viewModel.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: viewModel.loadEnrollments,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewModel.enrollments.isEmpty) {
            return const Center(child: Text('No enrollments found.'));
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadEnrollments,
            child: ListView.builder(
              itemCount: viewModel.enrollments.length,
              itemBuilder: (context, index) {
                return enrollmentCard(viewModel.enrollments[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddEnrollment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
