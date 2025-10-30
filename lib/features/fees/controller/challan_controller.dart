import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/challan_model.dart';
import '../../../data/models/combined_challan_model.dart';
import '../../students/service/student_service.dart';
import '../service/challan_service.dart';
import '../service/combined_challan_service.dart';

enum ChallanSection {
  admissionChallans,
  monthlyChallans,
  examChallans,
  miscChallans,
  multipleChallans,
}

class ChallanRecord {
  final int? id;
  final StudentModel student;
  final String challanType;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidDate;
  final String? month; // For monthly challans

  ChallanRecord({
    this.id,
    required this.student,
    required this.challanType,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.paidDate,
    this.month,
  });
}

class ChallanController extends GetxController {
  Rx<ChallanSection> selectedSection = ChallanSection.admissionChallans.obs;
  RxBool isLoading = true.obs;
  RxList<StudentModel> students = <StudentModel>[].obs;
  RxList<ChallanModel> challans = <ChallanModel>[].obs;
  RxList<CombinedChallanModel> combinedChallans = <CombinedChallanModel>[].obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
    loadChallanData();
    loadCombinedChallans();
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;
      final allStudents = await StudentService.getAllStudents();
      students.value = allStudents;
      await loadChallanData();
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

  Future<void> loadChallanData() async {
    try {
      isLoading.value = true;
      final allChallans = await ChallanService.fetchAllChallans();
      challans.value = allChallans;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load challans: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeSection(ChallanSection section) {
    selectedSection.value = section;
    // Reload challans when switching sections to ensure fresh data
    loadChallanData();
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

  List<ChallanModel> getChallansForSection(ChallanSection section) {
    return challans
        .where((challan) {
          switch (section) {
            case ChallanSection.admissionChallans:
              return challan.feesType == 'Admission';
            case ChallanSection.monthlyChallans:
              return challan.feesType == 'Monthly';
            case ChallanSection.examChallans:
              return challan.feesType == 'Exam';
            case ChallanSection.miscChallans:
              return challan.feesType == 'Misc';
            case ChallanSection.multipleChallans:
              return challan.feesType == 'Multiple';
          }
        })
        .where((challan) {
          if (searchQuery.value.isEmpty) return true;
          final query = searchQuery.value.toLowerCase();
          // Note: For now, we can't search by student name since we don't have student data joined
          // In a real implementation, you would join with students table or store student info in challan
          return challan.challanId.toLowerCase().contains(query);
        })
        .toList();
  }

  Future<void> generateChallan({
    required String studentId,
    required String feesType,
    required double amount,
    required String referenceFeeId,
    String? classId,
    String? month,
    String? examDetails,
    String? feeDetails,
  }) async {
    try {
      final challan = ChallanModel(
        studentId: studentId,
        classId: classId,
        feesType: feesType,
        amount: amount,
        referenceFeeId: referenceFeeId,
        status: 'Generated',
        month: month,
        examDetails: examDetails,
        feeDetails: feeDetails,
      );

      final success = await ChallanService.createChallan(challan);
      if (success) {
        // Reload challans to show the new one
        await loadChallanData();
        Get.snackbar(
          'Success',
          'Challan generated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to create challan');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate challan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadCombinedChallans() async {
    try {
      isLoading.value = true;
      final allCombinedChallans =
          await CombinedChallanService.fetchAllCombinedChallans();
      combinedChallans.value = allCombinedChallans;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load combined challans: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to refresh challans data
  Future<void> refreshChallans() async {
    await loadChallanData();
    await loadCombinedChallans();
  }
}
