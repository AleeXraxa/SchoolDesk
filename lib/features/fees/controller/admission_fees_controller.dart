import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/result_dialog.dart';
import '../service/admission_fees_service.dart';
import '../../../data/models/admission_fee_model.dart';

class AdmissionFeesController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<AdmissionFeeModel> pendingFees = <AdmissionFeeModel>[].obs;
  RxList<AdmissionFeeModel> paidFees = <AdmissionFeeModel>[].obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdmissionFees();
  }

  Future<void> fetchAdmissionFees() async {
    try {
      isLoading.value = true;
      final pending = await AdmissionFeesService.getPendingAdmissionFees();
      final paid = await AdmissionFeesService.getPaidAdmissionFees();

      pendingFees.value = pending;
      paidFees.value = paid;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load admission fees: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingFees() async {
    try {
      final pending = await AdmissionFeesService.getPendingAdmissionFees();
      pendingFees.value = pending;
    } catch (e) {
      print('Error fetching pending fees: $e');
    }
  }

  Future<void> fetchPaidFees() async {
    try {
      final paid = await AdmissionFeesService.getPaidAdmissionFees();
      paidFees.value = paid;
    } catch (e) {
      print('Error fetching paid fees: $e');
    }
  }

  Future<void> processPayment(int feeId, double paymentAmount) async {
    try {
      // Validate payment amount
      if (paymentAmount <= 0) {
        ResultDialog.showError(
          Get.context!,
          title: 'Invalid Payment Amount',
          message: 'Payment amount must be greater than 0.',
        );
        return;
      }

      // Get current fee to validate
      final currentFee = await AdmissionFeesService.getAdmissionFeeById(feeId);
      if (currentFee == null) {
        ResultDialog.showError(
          Get.context!,
          title: 'Fee Not Found',
          message: 'The admission fee record was not found.',
        );
        return;
      }

      // Check if payment amount exceeds remaining amount
      if (paymentAmount > currentFee.remainingAmount) {
        ResultDialog.showError(
          Get.context!,
          title: 'Invalid Payment Amount',
          message: 'Payment amount cannot exceed the remaining amount due.',
        );
        return;
      }

      // Process payment
      final success = await AdmissionFeesService.processPayment(
        feeId,
        paymentAmount,
      );

      if (success) {
        // Refresh data
        await fetchAdmissionFees();

        // Show success dialog
        ResultDialog.showSuccess(
          Get.context!,
          title: 'Payment Successful!',
          message: 'The admission fee payment has been processed successfully.',
        );
      } else {
        ResultDialog.showError(
          Get.context!,
          title: 'Payment Failed',
          message: 'Failed to process the payment. Please try again.',
        );
      }
    } catch (e) {
      ResultDialog.showError(
        Get.context!,
        title: 'Payment Error',
        message: 'An error occurred while processing the payment: $e',
      );
    }
  }

  Future<void> addAdmissionFeeForStudent(
    int studentId,
    double admissionFeeAmount,
  ) async {
    try {
      await AdmissionFeesService.createAdmissionFeeForStudent(
        studentId,
        admissionFeeAmount,
      );
      await fetchAdmissionFees(); // Refresh data
    } catch (e) {
      print('Error creating admission fee for student: $e');
      // Don't show error dialog here as it's called during student creation
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    // Filter logic can be implemented here if needed
  }

  List<AdmissionFeeModel> getFilteredPendingFees() {
    if (searchQuery.value.isEmpty) {
      return pendingFees;
    }

    final query = searchQuery.value.toLowerCase();
    return pendingFees.where((fee) {
      return (fee.studentName?.toLowerCase().contains(query) ?? false) ||
          (fee.rollNo?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<AdmissionFeeModel> getFilteredPaidFees() {
    if (searchQuery.value.isEmpty) {
      return paidFees;
    }

    final query = searchQuery.value.toLowerCase();
    return paidFees.where((fee) {
      return (fee.studentName?.toLowerCase().contains(query) ?? false) ||
          (fee.rollNo?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void clearFilters() {
    searchQuery.value = '';
  }
}
