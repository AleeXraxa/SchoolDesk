import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/database_service.dart';
import '../../../data/models/misc_fee_model.dart';
import '../../../data/models/misc_paid_fee_model.dart';
import '../../../features/classes/model/class_model.dart';
import '../../../features/classes/service/class_service.dart';
import '../service/misc_fees_service.dart';

class MiscFeesController extends GetxController {
  var isLoading = false.obs;
  var pendingFees = <MiscFeeModel>[].obs;
  var paidFees = <MiscPaidFeeModel>[].obs;
  var searchQuery = ''.obs;

  // View Fees filtering
  var selectedClass = ''.obs;
  var selectedMiscFeeType = ''.obs;
  var selectedMonth = ''.obs;
  var isViewFiltered = false.obs;
  var filteredPendingFees = <MiscFeeModel>[].obs;
  var filteredPaidFees = <MiscPaidFeeModel>[].obs;
  var filteredAggregatedPaidFees = <MiscPaidFeeModel>[].obs;

  // Statistics
  var totalPendingFees = 0.obs;
  var totalPaidFees = 0.obs;
  var totalPartialFees = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMiscFees();
  }

  Future<void> loadMiscFees() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadPendingFees(),
        loadPaidFees(),
        loadAggregatedPaidFees(),
      ]);
      _calculateStatistics();
    } catch (e) {
      print('MiscFeesController: Error loading misc fees: $e');
      Get.snackbar('Error', 'Failed to load misc fees');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingFees() async {
    try {
      final fees = await MiscFeesService.getPendingMiscFees();
      pendingFees.assignAll(fees);
    } catch (e) {
      print('MiscFeesController: Error loading pending fees: $e');
      rethrow;
    }
  }

  Future<void> loadPaidFees() async {
    try {
      final fees = await MiscFeesService.getPaidMiscFees();
      paidFees.assignAll(fees);
    } catch (e) {
      print('MiscFeesController: Error loading paid fees: $e');
      rethrow;
    }
  }

  void showGenerateFeesConfirmation() {
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
                width: MediaQuery.of(context).size.width > 800 ? 600 : 500,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 50.0, end: 0.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        builder: (context, offset, child) {
                          return Transform.translate(
                            offset: Offset(0, offset),
                            child: Opacity(
                              opacity: ((50 - offset) / 50).clamp(0.0, 1.0),
                              child: const Text(
                                '💰 Generate Misc Fees',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Form fields
                      _buildMiscGenerationForm(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildMiscGenerationForm() {
    final miscFeeTypeController = TextEditingController();
    final monthController = TextEditingController(
      text: DateFormat('MMMM yyyy').format(DateTime.now()),
    );
    final classFeeControllers = <int, TextEditingController>{}.obs;
    final selectedClasses = <int>[].obs;
    final enteredFees = <int, double>{}.obs;
    final classes = <ClassModel>[].obs;
    final isLoadingClasses = true.obs;
    final totalEstimatedFee = 0.0.obs;

    // Load classes
    _loadClassesForGeneration(
      classes,
      isLoadingClasses,
      classFeeControllers,
      enteredFees,
    );

    return Obx(() {
      if (isLoadingClasses.value) {
        return Container(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      // Calculate total estimated fee
      double total = 0.0;
      for (final classId in selectedClasses) {
        total += enteredFees[classId] ?? 0.0;
      }
      totalEstimatedFee.value = total;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.assignment_add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generate Misc Fees',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create new misc fee entries for selected classes',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey[300]!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Form Section
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Misc Fee Details Section
                  Text(
                    'Misc Fee Details',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Misc Fee Type Dropdown
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: null,
                            decoration: InputDecoration(
                              labelText: 'Misc Fee Type',
                              hintText: 'Select fee type',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.category,
                                color: Colors.blue[600],
                              ),
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items:
                                [
                                      'Library Fine',
                                      'Sports Fee',
                                      'Lab Maintenance',
                                      'Transportation',
                                      'Stationery',
                                      'Activity Fee',
                                      'Late Fee',
                                      'Other',
                                    ]
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              miscFeeTypeController.text = value ?? '';
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a misc fee type';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Month
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: monthController,
                            decoration: InputDecoration(
                              labelText: 'Month',
                              hintText: 'e.g., March 2024',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: Colors.blue[600],
                              ),
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Fee Setup Section
                  Row(
                    children: [
                      Text(
                        'Class-wise Fee Setup',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Set individual fee amounts for each class',
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Classes Table
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(Get.context!).size.height * 0.35,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Class Name',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Fee Amount (PKR)',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Select',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Classes List
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: classes.length,
                            itemBuilder: (context, index) {
                              final classItem = classes[index];
                              final feeController =
                                  classFeeControllers[classItem.id] ??
                                  TextEditingController();

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(
                                  milliseconds: 400 + (index * 50),
                                ),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Obx(() {
                                  final isSelected = selectedClasses.contains(
                                    classItem.id,
                                  );
                                  final feeAmount =
                                      enteredFees[classItem.id] ?? 0.0;
                                  final hasValidAmount = feeAmount > 0;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.05)
                                          : index % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.withOpacity(0.02),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[100]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.blue[600]
                                                      : Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  classItem.displayName,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected
                                                        ? Colors.black87
                                                        : Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected
                                                    ? (hasValidAmount
                                                          ? Colors.green[400]!
                                                          : Colors.orange[400]!)
                                                    : Colors.grey[300]!,
                                                width: isSelected ? 1.5 : 1,
                                              ),
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey[50],
                                            ),
                                            child: TextField(
                                              controller: feeController,
                                              keyboardType:
                                                  TextInputType.number,
                                              enabled: isSelected,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.black87
                                                    : Colors.grey[400],
                                              ),
                                              decoration: InputDecoration(
                                                hintText: isSelected
                                                    ? '0.00'
                                                    : 'Select first',
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                prefixIcon:
                                                    isSelected && hasValidAmount
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        color:
                                                            Colors.green[500],
                                                        size: 16,
                                                      )
                                                    : null,
                                                suffixText: isSelected
                                                    ? 'PKR'
                                                    : null,
                                                suffixStyle: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                              onChanged: (value) {
                                                final amount =
                                                    double.tryParse(
                                                      value ?? '',
                                                    ) ??
                                                    0.0;
                                                if (amount > 0) {
                                                  enteredFees[classItem.id!] =
                                                      amount;
                                                } else {
                                                  enteredFees.remove(
                                                    classItem.id,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? Colors.blue[600]
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.blue[600]!
                                                      : Colors.grey[300]!,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Checkbox(
                                                value: isSelected,
                                                onChanged: (value) {
                                                  if (value == true &&
                                                      classItem.id != null) {
                                                    selectedClasses.add(
                                                      classItem.id!,
                                                    );
                                                  } else if (classItem.id !=
                                                      null) {
                                                    selectedClasses.remove(
                                                      classItem.id,
                                                    );
                                                    feeController.clear();
                                                    enteredFees.remove(
                                                      classItem.id,
                                                    );
                                                  }
                                                },
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary Section
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.indigo[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Summary',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    '${selectedClasses.length} classes selected • Total: PKR ${totalEstimatedFee.value.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() {
                    final hasValidSelection =
                        selectedClasses.isNotEmpty &&
                        selectedClasses.every((classId) {
                          final amount = enteredFees[classId] ?? 0.0;
                          return amount > 0;
                        });

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: hasValidSelection
                            ? () => _showConfirmationDialog(
                                miscFeeTypeController.text.trim(),
                                monthController.text.trim(),
                                selectedClasses,
                                enteredFees,
                                classes,
                              )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasValidSelection
                              ? Colors.blue[600]
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: hasValidSelection ? 4 : 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shadowColor: hasValidSelection
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              size: 18,
                              color: hasValidSelection
                                  ? Colors.white
                                  : Colors.grey[300],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Generate Fees',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Future<void> _loadClassesForGeneration(
    RxList<ClassModel> classes,
    RxBool isLoading,
    RxMap<int, TextEditingController> feeControllers,
    RxMap<int, double> enteredFees,
  ) async {
    try {
      isLoading.value = true;
      final loadedClasses = await ClassService.getAllClasses();
      classes.assignAll(loadedClasses);

      // Initialize fee controllers for each class
      for (final classItem in loadedClasses) {
        if (classItem.id == null) continue;
        feeControllers[classItem.id!] = TextEditingController();
      }
    } catch (e) {
      print('MiscFeesController: Error loading classes: $e');
      Get.snackbar('Error', 'Failed to load classes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showConfirmationDialog(
    String miscFeeType,
    String month,
    List<int> selectedClassIds,
    RxMap<int, double> enteredFees,
    RxList<ClassModel> classes,
  ) async {
    if (miscFeeType.isEmpty || selectedClassIds.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    // Additional validation for selectedClassIds
    if (selectedClassIds.any((id) => id <= 0)) {
      Get.snackbar('Error', 'Invalid class selection detected');
      return;
    }

    // Validate fee amounts
    final classFees = <int, double>{};
    for (final classId in selectedClassIds) {
      final amount = enteredFees[classId] ?? 0.0;
      if (amount <= 0) {
        Get.snackbar(
          'Error',
          'Please enter valid fee amounts for all selected classes',
        );
        return;
      }
      classFees[classId] = amount;
    }

    // Validate that all selected classes have valid IDs
    for (final classId in selectedClassIds) {
      if (classId <= 0) {
        Get.snackbar('Error', 'Invalid class ID detected');
        return;
      }
    }

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
                width: 450,
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
                    // Title
                    const Text(
                      '⚠️ Confirm Fee Generation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Fee Type:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                miscFeeType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Month:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                month,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Classes:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${selectedClassIds.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Class-wise breakdown
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: selectedClassIds.map((classId) {
                            final classItem = classes.firstWhere(
                              (c) => c.id == classId,
                            );
                            final feeAmount = classFees[classId]!;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    classItem.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'PKR ${feeAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Warning text
                    const Text(
                      'This will create misc fee records for all students in the selected classes. Make sure the information is correct.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _proceedWithMiscGeneration(
                              miscFeeType,
                              month,
                              classFees,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Generate Fees',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      barrierDismissible: false,
    );
  }

  Future<void> _proceedWithMiscGeneration(
    String miscFeeType,
    String month,
    Map<int, double> classFees,
  ) async {
    Get.back(); // Close confirmation dialog
    Get.back(); // Close generation form dialog

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
      final message = await MiscFeesService.generateMiscFeesForClasses(
        miscFeeType,
        month,
        classFees,
      );
      await loadMiscFees();

      Get.back(); // Close loading dialog

      // Show success dialog
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
                  width: 350,
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
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '✅ Misc Fees Generated Successfully',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      print('MiscFeesController: Error generating misc fees: $e');

      // Show error dialog
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
                  width: 350,
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
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 20),
                      const Text(
                        '❌ Generation Failed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        e.toString().replaceFirst('Exception: ', ''),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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
  }

  Future<bool> processPayment(
    int feeId,
    double paymentAmount,
    String paymentMode,
  ) async {
    try {
      isLoading.value = true;
      final success = await MiscFeesService.processPartialPayment(
        feeId,
        paymentAmount,
        paymentMode,
      );

      if (success) {
        await loadMiscFees();
        // Success dialog will be shown in the view
      }

      return success;
    } catch (e) {
      print('MiscFeesController: Error processing payment: $e');
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<MiscPaidFeeModel>> getAggregatedPaidFees() async {
    try {
      // Get all paid misc fees
      final fees = await MiscFeesService.getPaidMiscFees();

      // Group fees by student and misc fee type
      final Map<String, List<MiscPaidFeeModel>> groupedFees = {};

      for (final fee in fees) {
        final key = '${fee.studentId}_${fee.miscFeeType}';
        if (!groupedFees.containsKey(key)) {
          groupedFees[key] = [];
        }
        groupedFees[key]!.add(fee);
      }

      // Create aggregated fees
      final List<MiscPaidFeeModel> aggregatedFees = [];

      for (final entry in groupedFees.entries) {
        final feeList = entry.value;
        final firstFee = feeList.first;

        // Calculate totals
        final totalPaidAmount = feeList.fold<double>(
          0.0,
          (sum, fee) => sum + fee.paidAmount,
        );

        // Use the most recent payment date
        final mostRecentPayment = feeList.reduce(
          (a, b) => a.paymentDate.isAfter(b.paymentDate) ? a : b,
        );

        // Get the total fee from the pending misc fee to calculate remaining amount
        double totalFee = 0.0;
        try {
          // Try to get the pending fee to get total amount
          final pendingFees = await MiscFeesService.getPendingMiscFees();
          final pendingFee = pendingFees.firstWhere(
            (fee) =>
                fee.studentId == firstFee.studentId &&
                fee.miscFeeType == firstFee.miscFeeType,
            orElse: () => MiscFeeModel(
              studentId: firstFee.studentId,
              classId: firstFee.classId,
              miscFeeType: firstFee.miscFeeType,
              month: '',
              totalFee: 0.0,
              paidAmount: 0.0,
              status: 'Pending',
            ),
          );
          totalFee = pendingFee.totalFee;
        } catch (e) {
          // If we can't get the pending fee, assume the paid amount is the total
          totalFee = totalPaidAmount;
        }

        aggregatedFees.add(
          MiscPaidFeeModel(
            id: firstFee.id,
            pendingMiscFeeId: firstFee.pendingMiscFeeId,
            studentId: firstFee.studentId,
            classId: firstFee.classId,
            miscFeeType: firstFee.miscFeeType,
            paidAmount: totalPaidAmount,
            paymentDate: mostRecentPayment.paymentDate,
            paymentMode: mostRecentPayment.paymentMode,
            createdAt: firstFee.createdAt,
            studentName: firstFee.studentName,
            rollNo: firstFee.rollNo,
            className: firstFee.className,
            section: firstFee.section,
            totalFee: totalFee,
            remainingAmount: totalFee - totalPaidAmount,
          ),
        );
      }

      // Sort by most recent payment date
      aggregatedFees.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

      return aggregatedFees;
    } catch (e) {
      print('MiscFeesController: Error getting aggregated paid fees: $e');
      return [];
    }
  }

  RxList<MiscPaidFeeModel> aggregatedPaidFees = <MiscPaidFeeModel>[].obs;

  Future<void> loadAggregatedPaidFees() async {
    try {
      isLoading.value = true;
      final fees = await getAggregatedPaidFees();
      aggregatedPaidFees.assignAll(fees);
    } catch (e) {
      print('MiscFeesController: Error loading aggregated paid fees: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<MiscPaidFeeModel> getDisplayedAggregatedPaidFees() {
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

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<MiscFeeModel> getFilteredPendingFees() {
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

  List<MiscPaidFeeModel> getFilteredPaidFees() {
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

  void _calculateStatistics() {
    totalPendingFees.value = pendingFees.where((fee) => fee.isPending).length;
    totalPaidFees.value = paidFees.length;
    totalPartialFees.value = pendingFees
        .where((fee) => fee.isPartiallyPaid)
        .length;
  }

  Future<String> generateMiscFeesForClass(
    int classId,
    String month,
    String miscFeeType,
    double feeAmount, {
    String? description,
  }) async {
    try {
      isLoading.value = true;

      // Check for existing fees
      final db = await DatabaseService.database;
      final existingFees = await db.rawQuery(
        '''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.class_id = ? AND mfp.misc_fee_type = ? AND mfp.month = ?
        ''',
        [classId, miscFeeType, month],
      );

      if (existingFees.isNotEmpty) {
        throw Exception(
          'Misc fees for "$miscFeeType" - "$month" already exist for this class',
        );
      }

      final message = await MiscFeesService.generateMiscFeesForClass(
        classId,
        month,
        miscFeeType,
        feeAmount,
        description: description,
      );
      await loadMiscFees();
      return message;
    } catch (e) {
      print('MiscFeesController: Error generating misc fees for class: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> generateMiscFeeForStudent(
    int studentId,
    String month,
    String miscFeeType,
    double feeAmount, {
    String? description,
  }) async {
    try {
      isLoading.value = true;

      // Check for existing fees
      final db = await DatabaseService.database;
      final existingFees = await db.rawQuery(
        '''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.student_id = ? AND mfp.misc_fee_type = ? AND mfp.month = ?
        ''',
        [studentId, miscFeeType, month],
      );

      if (existingFees.isNotEmpty) {
        throw Exception(
          'Misc fees for "$miscFeeType" - "$month" already exist for this student',
        );
      }

      final message = await MiscFeesService.generateMiscFeeForStudent(
        studentId,
        month,
        miscFeeType,
        feeAmount,
        description: description,
      );
      await loadMiscFees();
      return message;
    } catch (e) {
      print('MiscFeesController: Error generating misc fee for student: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadMiscFees();
  }

  Future<void> viewFeesByClassAndType(
    String className,
    String miscFeeType, {
    String? section,
  }) async {
    try {
      isLoading.value = true;
      selectedClass.value = section != null ? '$className $section' : className;
      selectedMiscFeeType.value = miscFeeType;
      isViewFiltered.value = true;

      print(
        "Filtering by: className='$className', section='$section', miscFeeType='$miscFeeType'",
      );

      // Load filtered data
      final pending = await MiscFeesService.getPendingMiscFeesByClassAndType(
        className,
        miscFeeType,
        section: section,
      );
      final paid = await MiscFeesService.getPaidMiscFeesByClassAndType(
        className,
        miscFeeType,
        section: section,
      );

      print("Filtered results: pending=${pending.length}, paid=${paid.length}");

      filteredPendingFees.assignAll(pending);
      filteredPaidFees.assignAll(paid);

      // Filter aggregated paid fees by the same criteria
      final aggregatedPaid = await getAggregatedPaidFees();
      final filteredAggregatedPaid = aggregatedPaid.where((fee) {
        final classMatch = fee.className == className;
        final typeMatch = fee.miscFeeType == miscFeeType;
        final sectionMatch = section == null || fee.section == section;
        return classMatch && typeMatch && sectionMatch;
      }).toList();

      filteredAggregatedPaidFees.assignAll(filteredAggregatedPaid);

      _calculateFilteredStatistics();
    } catch (e) {
      print('MiscFeesController: Error viewing fees by class and type: $e');
      Get.snackbar('Error', 'Failed to load filtered fees');
    } finally {
      isLoading.value = false;
    }
  }

  void clearViewFilter() {
    selectedClass.value = '';
    selectedMiscFeeType.value = '';
    selectedMonth.value = '';
    isViewFiltered.value = false;
    filteredPendingFees.clear();
    filteredPaidFees.clear();
    filteredAggregatedPaidFees.clear();
  }

  List<MiscFeeModel> getDisplayedPendingFees() {
    if (isViewFiltered.value) {
      return getFilteredPendingFeesForView();
    }
    return getFilteredPendingFees();
  }

  List<MiscPaidFeeModel> getDisplayedPaidFees() {
    if (isViewFiltered.value) {
      return getFilteredPaidFeesForView();
    }
    return getFilteredPaidFees();
  }

  List<MiscFeeModel> getFilteredPendingFeesForView() {
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

  List<MiscPaidFeeModel> getFilteredPaidFeesForView() {
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

  List<MiscPaidFeeModel> getFilteredAggregatedPaidFeesForView() {
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
      totalPaidFees.value = filteredPaidFees.length;
      totalPartialFees.value = filteredPendingFees
          .where((fee) => fee.isPartiallyPaid)
          .length;
    } else {
      _calculateStatistics();
    }
  }

  Future<void> viewFeesByClassAndTypeAndMonth(
    String className,
    String miscFeeType,
    String month, {
    String? section,
  }) async {
    try {
      isLoading.value = true;
      selectedClass.value = section != null ? '$className $section' : className;
      selectedMiscFeeType.value = miscFeeType;
      selectedMonth.value = month;
      isViewFiltered.value = true;

      print(
        "Filtering by: className='$className', section='$section', miscFeeType='$miscFeeType', month='$month'",
      );

      // Load filtered data
      final pending =
          await MiscFeesService.getPendingMiscFeesByClassAndTypeAndMonth(
            className,
            miscFeeType,
            month,
            section: section,
          );

      // Load paid fees with month filtering via JOIN with pending table
      final paid = await MiscFeesService.getPaidMiscFeesByClassAndTypeAndMonth(
        className,
        miscFeeType,
        month,
        section: section,
      );

      print("Filtered results: pending=${pending.length}, paid=${paid.length}");

      filteredPendingFees.assignAll(pending);
      filteredPaidFees.assignAll(paid);

      // Filter aggregated paid fees by the same criteria
      final aggregatedPaid = await getAggregatedPaidFees();
      final filteredAggregatedPaid = aggregatedPaid.where((fee) {
        final classMatch = fee.className == className;
        final typeMatch = fee.miscFeeType == miscFeeType;
        final sectionMatch = section == null || fee.section == section;
        return classMatch && typeMatch && sectionMatch;
      }).toList();

      filteredAggregatedPaidFees.assignAll(filteredAggregatedPaid);

      _calculateFilteredStatistics();
    } catch (e) {
      print(
        'MiscFeesController: Error viewing fees by class, type and month: $e',
      );
      Get.snackbar('Error', 'Failed to load filtered fees');
    } finally {
      isLoading.value = false;
    }
  }
}
