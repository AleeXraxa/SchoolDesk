import 'package:get/get.dart';
import '../../../data/models/monthly_fee_model.dart';
import '../../../data/models/monthly_payment_history_model.dart';
import '../../../data/models/monthly_paid_fees_model.dart';
import '../service/monthly_fees_service.dart';

class MonthlyFeesController extends GetxController {
  var isLoading = false.obs;
  var pendingFees = <MonthlyFeeModel>[].obs;
  var paidFees = <MonthlyFeeModel>[].obs;
  var aggregatedPaidFees = <MonthlyPaidFeesModel>[].obs;
  var allFees = <MonthlyFeeModel>[].obs;
  var searchQuery = ''.obs;

  // Statistics
  var totalPendingFees = 0.obs;
  var totalPaidFees = 0.obs;
  var totalPartialFees = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMonthlyFees();
  }

  Future<void> loadMonthlyFees() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadPendingFees(),
        loadPaidFees(),
        loadAggregatedPaidFees(),
        loadAllFees(),
      ]);
      _calculateStatistics();
    } catch (e) {
      print('MonthlyFeesController: Error loading monthly fees: $e');
      Get.snackbar('Error', 'Failed to load monthly fees');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingFees() async {
    try {
      final fees = await MonthlyFeesService.getPendingMonthlyFees();
      pendingFees.assignAll(fees);
    } catch (e) {
      print('MonthlyFeesController: Error loading pending fees: $e');
      rethrow;
    }
  }

  Future<void> loadPaidFees() async {
    try {
      final fees = await MonthlyFeesService.getPaidMonthlyFees();
      paidFees.assignAll(fees);
    } catch (e) {
      print('MonthlyFeesController: Error loading paid fees: $e');
      rethrow;
    }
  }

  Future<void> loadAggregatedPaidFees() async {
    try {
      final fees = await MonthlyFeesService.getAggregatedPaidMonthlyFees();
      aggregatedPaidFees.assignAll(fees);
    } catch (e) {
      print('MonthlyFeesController: Error loading aggregated paid fees: $e');
      rethrow;
    }
  }

  Future<void> loadAllFees() async {
    try {
      final fees = await MonthlyFeesService.getAllMonthlyFees();
      allFees.assignAll(fees);
    } catch (e) {
      print('MonthlyFeesController: Error loading all fees: $e');
      rethrow;
    }
  }

  Future<void> generateMonthlyFees() async {
    try {
      isLoading.value = true;
      final message =
          await MonthlyFeesService.generateMonthlyFeesForCurrentMonth();
      await loadMonthlyFees();
      Get.snackbar('Success', message, duration: const Duration(seconds: 3));
    } catch (e) {
      print('MonthlyFeesController: Error generating monthly fees: $e');
      Get.snackbar('Error', 'Failed to generate monthly fees: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> processPayment(
    int feeId,
    double paymentAmount,
    String modeOfPayment,
    String? remarks,
  ) async {
    try {
      isLoading.value = true;
      final success = await MonthlyFeesService.processPartialPayment(
        feeId,
        paymentAmount,
        modeOfPayment,
        remarks,
      );

      if (success) {
        await loadMonthlyFees();
        // No snackbar here - success dialog will be shown in the view
      }

      return success;
    } catch (e) {
      print('MonthlyFeesController: Error processing payment: $e');
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<MonthlyPaymentHistoryModel>> getPaymentHistory(
    int monthlyFeeId,
  ) async {
    try {
      return await MonthlyFeesService.getPaymentHistoryByMonthlyFeeId(
        monthlyFeeId,
      );
    } catch (e) {
      print('MonthlyFeesController: Error getting payment history: $e');
      return [];
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<MonthlyFeeModel> getFilteredPendingFees() {
    if (searchQuery.value.isEmpty) {
      return pendingFees;
    }
    return pendingFees.where((fee) {
      final studentName = fee.studentName?.toLowerCase() ?? '';
      final rollNo = fee.rollNo?.toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return studentName.contains(query) || rollNo.contains(query);
    }).toList();
  }

  List<MonthlyFeeModel> getFilteredPaidFees() {
    if (searchQuery.value.isEmpty) {
      return paidFees;
    }
    return paidFees.where((fee) {
      final studentName = fee.studentName?.toLowerCase() ?? '';
      final rollNo = fee.rollNo?.toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return studentName.contains(query) || rollNo.contains(query);
    }).toList();
  }

  List<MonthlyPaidFeesModel> getFilteredAggregatedPaidFees() {
    if (searchQuery.value.isEmpty) {
      return aggregatedPaidFees;
    }
    return aggregatedPaidFees.where((fee) {
      final studentName = fee.studentName?.toLowerCase() ?? '';
      final rollNo = fee.rollNo?.toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return studentName.contains(query) || rollNo.contains(query);
    }).toList();
  }

  void _calculateStatistics() {
    totalPendingFees.value = pendingFees.where((fee) => fee.isPending).length;
    totalPaidFees.value = paidFees.where((fee) => fee.isPaid).length;
    totalPartialFees.value = pendingFees.where((fee) => fee.isPartial).length;
  }

  Future<void> refreshData() async {
    await loadMonthlyFees();
  }
}
