import 'package:flutter/material.dart';

import '../models/grade.dart';
import '../repositories/grade_repository.dart';

class GradeViewModel extends ChangeNotifier {
  final GradeRepository _repository = GradeRepository();

  List<Grade> grades = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadGrades() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      grades = await _repository.getGrades();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addGrade(Grade grade) async {
    try {
      await _repository.addGrade(grade);
      await loadGrades();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGrade(Grade grade) async {
    try {
      await _repository.updateGrade(grade);
      await loadGrades();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGrade(int gradeId) async {
    try {
      await _repository.deleteGrade(gradeId);
      await loadGrades();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
