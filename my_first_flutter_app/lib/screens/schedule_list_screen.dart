import 'package:flutter/material.dart';

import '../models/schedule.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';
import '../viewmodels/schedule_viewmodel.dart';
import 'add_schedule_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => ScheduleListScreenState();
}

class ScheduleListScreenState extends State<ScheduleListScreen> {
  final ScheduleViewModel viewModel = ScheduleViewModel();
  final SubjectRepository subjectRepository = SubjectRepository();

  List<Subject> subjects = [];
  bool isLoadingSubjects = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoadingSubjects = true;
    });

    try {
      final result = await subjectRepository.getSubjects();

      if (!mounted) return;

      subjects = result;
      await viewModel.loadSchedules();
    } catch (e) {
      viewModel.errorMessage = e.toString();
    }

    if (!mounted) return;

    setState(() {
      isLoadingSubjects = false;
    });
  }

  Subject? getSubject(int subjectId) {
    try {
      return subjects.firstWhere((subject) => subject.subjectId == subjectId);
    } catch (_) {
      return null;
    }
  }

  Future<void> openAddSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddScheduleScreen()),
    );

    if (result == true) {
      await loadData();
    }
  }

  Future<void> openEditSchedule(Schedule schedule) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleScreen(schedule: schedule),
      ),
    );

    if (result == true) {
      await loadData();
    }
  }

  Future<void> deleteSchedule(Schedule schedule) async {
    if (schedule.scheduleId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
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

    if (confirm != true) return;

    final success = await viewModel.deleteSchedule(schedule.scheduleId!);

    if (!mounted) return;

    if (success) {
      await loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule deleted successfully from Neon!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: ${viewModel.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget scheduleCard(Schedule schedule) {
    final subject = getSubject(schedule.subjectId);
    final available = schedule.availableSlots;
    final isFull = available == 0;

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
                const Icon(Icons.calendar_month, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subject?.subjectCode ?? 'Unknown Subject',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => openEditSchedule(schedule),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () => deleteSchedule(schedule),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subject?.subjectName ?? 'Subject not found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 20),
            detailRow(Icons.today, schedule.dayOfWeek),
            detailRow(
              Icons.access_time,
              '${schedule.startTime} - ${schedule.endTime}',
            ),
            detailRow(
              Icons.room,
              schedule.room?.isNotEmpty == true
                  ? schedule.room!
                  : 'No room assigned',
            ),
            detailRow(Icons.people, 'Total Capacity: ${schedule.slotCapacity}'),
            const SizedBox(height: 10),
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
                    'Enrolled Students: ${schedule.enrolledCount}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Available Slots: $available',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFull ? Colors.red : Colors.green.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: schedule.slotCapacity > 0
                        ? (schedule.enrolledCount / schedule.slotCapacity)
                              .clamp(0.0, 1.0)
                        : 0,
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
        title: const Text('Schedules'),
        actions: [
          IconButton(onPressed: loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoadingSubjects
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
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
                          const Text('Failed to load schedules.'),
                          const SizedBox(height: 8),
                          Text(
                            viewModel.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: loadData,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (viewModel.schedules.isEmpty) {
                  return const Center(child: Text('No schedules found.'));
                }

                return RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    itemCount: viewModel.schedules.length,
                    itemBuilder: (context, index) {
                      return scheduleCard(viewModel.schedules[index]);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }
}
