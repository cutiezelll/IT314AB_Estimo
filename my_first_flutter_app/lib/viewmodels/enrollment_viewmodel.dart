import 'package:flutter/material.dart';

import '../models/enrollment.dart';
import '../repositories/enrollment_repository.dart';

class EnrollmentViewModel extends ChangeNotifier {
  final EnrollmentRepository enrollmentRepository = EnrollmentRepository();

  List<Enrollment> enrollments = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadEnrollments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      enrollments = await enrollmentRepository.getEnrollments();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addEnrollment(Enrollment enrollment) async {
    try {
      await enrollmentRepository.addEnrollment(enrollment);
      await loadEnrollments();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> dropEnrollment(int enrollmentId) async {
    try {
      await enrollmentRepository.dropEnrollment(enrollmentId);
      await loadEnrollments();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> reactivateEnrollment(int enrollmentId) async {
    try {
      await enrollmentRepository.reactivateEnrollment(enrollmentId);
      await loadEnrollments();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }
}
