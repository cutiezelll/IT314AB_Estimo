import 'package:flutter/material.dart';

import '../models/schedule.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';
import '../viewmodels/schedule_viewmodel.dart';

class AddScheduleScreen extends StatefulWidget {
  final Schedule? schedule;

  const AddScheduleScreen({super.key, this.schedule});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  final SubjectRepository subjectRepository = SubjectRepository();
  final ScheduleViewModel viewModel = ScheduleViewModel();

  List<Subject> subjects = [];

  int? selectedSubjectId;
  String? selectedDay;

  final roomController = TextEditingController();
  final capacityController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isLoading = true;
  bool isSubmitting = false;

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  bool get isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final schedule = widget.schedule!;

      selectedSubjectId = schedule.subjectId;
      selectedDay = schedule.dayOfWeek;
      roomController.text = schedule.room ?? '';
      capacityController.text = schedule.slotCapacity.toString();

      startTime = parseTime(schedule.startTime);
      endTime = parseTime(schedule.endTime);
    }

    loadSubjects();
  }

  TimeOfDay parseTime(String value) {
    final parts = value.split(':');

    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> loadSubjects() async {
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
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load subjects: $e')));
    }
  }

  Future<void> selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? startTime ?? TimeOfDay.now()
          : endTime ?? startTime ?? TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  Future<void> saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSubjectId == null ||
        selectedDay == null ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be later than start time.'),
        ),
      );
      return;
    }

    final capacity = int.tryParse(capacityController.text.trim());

    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot capacity must be greater than zero.'),
        ),
      );
      return;
    }

    final schedule = Schedule(
      scheduleId: widget.schedule?.scheduleId,
      subjectId: selectedSubjectId!,
      dayOfWeek: selectedDay!,
      startTime: formatTime(startTime!),
      endTime: formatTime(endTime!),
      room: roomController.text.trim().isEmpty
          ? null
          : roomController.text.trim(),
      slotCapacity: capacity,
    );

    setState(() {
      isSubmitting = true;
    });

    final success = isEditing
        ? await viewModel.updateSchedule(schedule)
        : await viewModel.addSchedule(schedule);

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Schedule updated successfully!'
                : 'Schedule added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save schedule: ${viewModel.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
          child: Text(time == null ? 'Select time' : time.format(context)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    roomController.dispose();
    capacityController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
          ? const Center(
              child: Text(
                'No subjects available. Please add a subject first.',
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedSubjectId,
                      decoration: const InputDecoration(
                        labelText: 'Select Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: subjects.map((subject) {
                        return DropdownMenuItem<int>(
                          value: subject.subjectId,
                          child: Text(
                            '${subject.subjectCode} - ${subject.subjectName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubjectId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a subject.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Day of Week',
                        border: OutlineInputBorder(),
                      ),
                      items: days.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a day.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        buildTimeField(
                          label: 'Start Time',
                          time: startTime,
                          onPressed: () => selectTime(true),
                        ),
                        const SizedBox(width: 12),
                        buildTimeField(
                          label: 'End Time',
                          time: endTime,
                          onPressed: () => selectTime(false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: roomController,
                      decoration: const InputDecoration(
                        labelText: 'Room',
                        hintText: 'Enter classroom or laboratory',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.room),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Slot Capacity',
                        hintText: 'Enter maximum number of students',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter slot capacity.';
                        }

                        final number = int.tryParse(value);

                        if (number == null || number <= 0) {
                          return 'Enter a valid positive number.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : saveSchedule,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(
                          isSubmitting
                              ? 'Saving...'
                              : isEditing
                              ? 'Update Schedule'
                              : 'Add Schedule',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
