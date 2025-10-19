import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/student_model.dart';
import '../../students/service/student_service.dart';

enum FeesSection { admissionFees, monthlyFees, examFees, miscFees }

class FeeRecord {
  final int? id;
  final StudentModel student;
  final String feeType;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidDate;
  final String? month; // For monthly fees

  FeeRecord({
    this.id,
    required this.student,
    required this.feeType,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.paidDate,
    this.month,
  });
}

class FeesController extends GetxController {
  Rx<FeesSection> selectedSection = FeesSection.admissionFees.obs;
  RxBool isLoading = true.obs;
  RxList<StudentModel> students = <StudentModel>[].obs;
  RxList<FeeRecord> pendingFees = <FeeRecord>[].obs;
  RxList<FeeRecord> paidFees = <FeeRecord>[].obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;
      final allStudents = await StudentService.getAllStudents();
      students.value = allStudents;
      await loadFeeData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load students: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFeeData() async {
    // Generate mock fee data for demonstration
    // In a real app, this would come from a fees table in the database
    final List<FeeRecord> allFees = [];

    for (final student in students) {
      // Admission fees
      allFees.add(
        FeeRecord(
          student: student,
          feeType: 'Admission Fee',
          amount: student.admissionFees,
          dueDate: student.admissionDate,
          isPaid: true, // Assume admission fees are paid
          paidDate: student.admissionDate,
        ),
      );

      // Monthly fees for current month
      final now = DateTime.now();
      final currentMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final isPaid = now.day <= 10; // Paid if before 10th of month

      allFees.add(
        FeeRecord(
          student: student,
          feeType: 'Monthly Fee',
          amount: student.monthlyFees,
          dueDate: DateTime(now.year, now.month, 10),
          isPaid: isPaid,
          paidDate: isPaid ? DateTime(now.year, now.month, 5) : null,
          month: currentMonth,
        ),
      );

      // Exam fees
      final examTypes = ['Mid-term', 'Final', 'Unit Test'];
      for (int i = 0; i < examTypes.length; i++) {
        allFees.add(
          FeeRecord(
            student: student,
            feeType: '${examTypes[i]} Exam',
            amount: examTypes[i] == 'Mid-term'
                ? 500
                : examTypes[i] == 'Final'
                ? 1000
                : 200,
            dueDate: DateTime(now.year, now.month, 15 + i * 7),
            isPaid: i % 2 == 0, // Alternate paid/unpaid
            paidDate: i % 2 == 0
                ? DateTime(now.year, now.month, 10 + i * 7)
                : null,
          ),
        );
      }

      // Misc fees
      final miscFees = [
        'Lab Fee',
        'Transportation',
        'Library Fee',
        'Sports Fee',
      ];
      for (int i = 0; i < miscFees.length; i++) {
        allFees.add(
          FeeRecord(
            student: student,
            feeType: miscFees[i],
            amount: [200.0, 300.0, 150.0, 250.0][i],
            dueDate: DateTime(now.year, now.month, 20 + i * 5),
            isPaid: i % 3 != 0, // Some unpaid
            paidDate: i % 3 != 0
                ? DateTime(now.year, now.month, 15 + i * 5)
                : null,
          ),
        );
      }
    }

    // Separate into pending and paid
    pendingFees.value = allFees.where((fee) => !fee.isPaid).toList();
    paidFees.value = allFees.where((fee) => fee.isPaid).toList();
  }

  void changeSection(FeesSection section) {
    selectedSection.value = section;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<StudentModel> getFilteredStudents() {
    if (searchQuery.value.isEmpty) {
      return students;
    }

    return students.where((student) {
      final query = searchQuery.value.toLowerCase();
      return student.studentName.toLowerCase().contains(query) ||
          student.rollNo.toLowerCase().contains(query) ||
          student.fatherName.toLowerCase().contains(query);
    }).toList();
  }

  List<FeeRecord> getPendingFeesForSection(FeesSection section) {
    return pendingFees
        .where((fee) {
          switch (section) {
            case FeesSection.admissionFees:
              return fee.feeType == 'Admission Fee';
            case FeesSection.monthlyFees:
              return fee.feeType == 'Monthly Fee';
            case FeesSection.examFees:
              return fee.feeType.contains('Exam');
            case FeesSection.miscFees:
              return !fee.feeType.contains('Exam') &&
                  fee.feeType != 'Admission Fee' &&
                  fee.feeType != 'Monthly Fee';
          }
        })
        .where((fee) {
          if (searchQuery.value.isEmpty) return true;
          final query = searchQuery.value.toLowerCase();
          return fee.student.studentName.toLowerCase().contains(query) ||
              fee.student.rollNo.toLowerCase().contains(query);
        })
        .toList();
  }

  List<FeeRecord> getPaidFeesForSection(FeesSection section) {
    return paidFees
        .where((fee) {
          switch (section) {
            case FeesSection.admissionFees:
              return fee.feeType == 'Admission Fee';
            case FeesSection.monthlyFees:
              return fee.feeType == 'Monthly Fee';
            case FeesSection.examFees:
              return fee.feeType.contains('Exam');
            case FeesSection.miscFees:
              return !fee.feeType.contains('Exam') &&
                  fee.feeType != 'Admission Fee' &&
                  fee.feeType != 'Monthly Fee';
          }
        })
        .where((fee) {
          if (searchQuery.value.isEmpty) return true;
          final query = searchQuery.value.toLowerCase();
          return fee.student.studentName.toLowerCase().contains(query) ||
              fee.student.rollNo.toLowerCase().contains(query);
        })
        .toList();
  }

  Future<void> markFeeAsPaid(FeeRecord fee) async {
    try {
      // In a real app, this would update the database
      final index = pendingFees.indexWhere(
        (f) => f.id == fee.id && f.student.id == fee.student.id,
      );
      if (index != -1) {
        final paidFee = FeeRecord(
          id: fee.id,
          student: fee.student,
          feeType: fee.feeType,
          amount: fee.amount,
          dueDate: fee.dueDate,
          isPaid: true,
          paidDate: DateTime.now(),
          month: fee.month,
        );

        pendingFees.removeAt(index);
        paidFees.add(paidFee);

        Get.snackbar(
          'Success',
          'Fee marked as paid successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update fee status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
