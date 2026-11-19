import 'package:flutter/material.dart';

import '../models/schedule.dart';
import '../repositories/schedule_repository.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleRepository scheduleRepository = ScheduleRepository();

  List<Schedule> schedules = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadSchedules() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      schedules = await scheduleRepository.getSchedules();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addSchedule(Schedule schedule) async {
    try {
      await scheduleRepository.addSchedule(schedule);
      await loadSchedules();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      await scheduleRepository.updateSchedule(schedule);
      await loadSchedules();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(int scheduleId) async {
    try {
      await scheduleRepository.deleteSchedule(scheduleId);
      await loadSchedules();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
