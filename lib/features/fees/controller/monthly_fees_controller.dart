import 'package:flutter/material.dart';
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

  // View Fees filtering
  var selectedClass = ''.obs;
  var selectedMonth = ''.obs;
  var isViewFiltered = false.obs;
  var filteredPendingFees = <MonthlyFeeModel>[].obs;
  var filteredPaidFees = <MonthlyFeeModel>[].obs;
  var filteredAggregatedPaidFees = <MonthlyPaidFeesModel>[].obs;

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

  void showGenerateFeesConfirmation() {
    final now = DateTime.now();
    final currentMonth = '${_getMonthName(now.month)} ${now.year}';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Confirmation icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.assignment,
                              color: Colors.orange,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Title
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 50.0, end: 0.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: Opacity(
                            opacity: (50 - offset) / 50,
                            child: const Text(
                              '🧾 Generate Monthly Fees?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Description
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            'You are about to generate monthly fees for $currentMonth.\n\nThis will create fee records for all active students who don\'t have fees generated for this month.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Preview section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Month: $currentMonth',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Action: Create monthly fee entries for all active students',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Generate button
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _proceedWithGeneration(currentMonth),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Generate',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false, // Prevent accidental dismissal
    );
  }

  Future<void> _proceedWithGeneration(String currentMonth) async {
    // Close confirmation dialog
    Get.back();

    // Show loading dialog
    Get.dialog(
      const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(child: CircularProgressIndicator()),
      ),
      barrierDismissible: false,
    );

    try {
      final message =
          await MonthlyFeesService.generateMonthlyFeesForCurrentMonth();
      await loadMonthlyFees();

      // Close loading dialog
      Get.back();

      // Show appropriate result dialog
      if (message.contains('already been generated')) {
        // Show info dialog for already generated
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Info icon
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Title
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 50.0, end: 0.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          builder: (context, offset, child) {
                            return Transform.translate(
                              offset: Offset(0, offset),
                              child: Opacity(
                                opacity: (50 - offset) / 50,
                                child: const Text(
                                  'ℹ️ Fees Already Generated',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Message
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // OK button
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () => Get.back(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          barrierDismissible: true,
        );
      } else {
        // Show success dialog for newly generated fees
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success icon
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 30,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Title
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 50.0, end: 0.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          builder: (context, offset, child) {
                            return Transform.translate(
                              offset: Offset(0, offset),
                              child: Opacity(
                                opacity: (50 - offset) / 50,
                                child: const Text(
                                  '✅ Monthly Fees Generated Successfully',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Message
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // OK button
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () => Get.back(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          barrierDismissible: true,
        );
      }
    } catch (e) {
      // Close loading dialog
      Get.back();
      print('MonthlyFeesController: Error generating monthly fees: $e');
      Get.snackbar('Error', 'Failed to generate monthly fees: $e');
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
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

  Future<void> viewFeesByClassAndMonth(
    String className,
    String month, {
    String? section,
  }) async {
    try {
      isLoading.value = true;
      selectedClass.value = section != null ? '$className $section' : className;
      selectedMonth.value = month;
      isViewFiltered.value = true;

      // Debug logging
      print(
        "Filtering by: className='$className', section='$section', month='$month'",
      );

      // Load filtered data
      final pending =
          await MonthlyFeesService.getPendingMonthlyFeesByClassAndMonth(
            className,
            month,
            section: section,
          );
      final paid = await MonthlyFeesService.getPaidMonthlyFeesByClassAndMonth(
        className,
        month,
        section: section,
      );
      final aggregatedPaid =
          await MonthlyFeesService.getAggregatedPaidMonthlyFeesByClassAndMonth(
            className,
            month,
            section: section,
          );

      // Debug logging
      print(
        "Filtered results: pending=${pending.length}, paid=${paid.length}, aggregatedPaid=${aggregatedPaid.length}",
      );

      filteredPendingFees.assignAll(pending);
      filteredPaidFees.assignAll(paid);
      filteredAggregatedPaidFees.assignAll(aggregatedPaid);

      _calculateFilteredStatistics();
    } catch (e) {
      print('MonthlyFeesController: Error viewing fees by class and month: $e');
      Get.snackbar('Error', 'Failed to load filtered fees');
    } finally {
      isLoading.value = false;
    }
  }

  void clearViewFilter() {
    selectedClass.value = '';
    selectedMonth.value = '';
    isViewFiltered.value = false;
    filteredPendingFees.clear();
    filteredPaidFees.clear();
    filteredAggregatedPaidFees.clear();
  }

  List<MonthlyFeeModel> getDisplayedPendingFees() {
    if (isViewFiltered.value) {
      return getFilteredPendingFeesForView();
    }
    return getFilteredPendingFees();
  }

  List<MonthlyFeeModel> getDisplayedPaidFees() {
    if (isViewFiltered.value) {
      return getFilteredPaidFeesForView();
    }
    return getFilteredPaidFees();
  }

  List<MonthlyPaidFeesModel> getDisplayedAggregatedPaidFees() {
    if (isViewFiltered.value) {
      return getFilteredAggregatedPaidFeesForView();
    }
    return getFilteredAggregatedPaidFees();
  }

  List<MonthlyFeeModel> getFilteredPendingFeesForView() {
    if (searchQuery.value.isEmpty) {
      return filteredPendingFees;
    }
    return filteredPendingFees.where((fee) {
      final studentName = fee.studentName?.toLowerCase() ?? '';
      final rollNo = fee.rollNo?.toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return studentName.contains(query) || rollNo.contains(query);
    }).toList();
  }

  List<MonthlyFeeModel> getFilteredPaidFeesForView() {
    if (searchQuery.value.isEmpty) {
      return filteredPaidFees;
    }
    return filteredPaidFees.where((fee) {
      final studentName = fee.studentName?.toLowerCase() ?? '';
      final rollNo = fee.rollNo?.toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return studentName.contains(query) || rollNo.contains(query);
    }).toList();
  }

  List<MonthlyPaidFeesModel> getFilteredAggregatedPaidFeesForView() {
    if (searchQuery.value.isEmpty) {
      return filteredAggregatedPaidFees;
    }
    return filteredAggregatedPaidFees.where((fee) {
      final studentName = fee.studentName?.toLowerCase() ?? '';
      final rollNo = fee.rollNo?.toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return studentName.contains(query) || rollNo.contains(query);
    }).toList();
  }

  void _calculateFilteredStatistics() {
    if (isViewFiltered.value) {
      totalPendingFees.value = filteredPendingFees
          .where((fee) => fee.isPending)
          .length;
      totalPaidFees.value = filteredPaidFees.where((fee) => fee.isPaid).length;
      totalPartialFees.value = filteredPendingFees
          .where((fee) => fee.isPartial)
          .length;
    } else {
      _calculateStatistics();
    }
  }
}
