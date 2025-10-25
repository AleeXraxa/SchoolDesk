import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database_service.dart';
import '../controller/misc_fees_controller.dart';

class MiscFeesFilterDialog extends StatefulWidget {
  const MiscFeesFilterDialog({super.key});

  @override
  State<MiscFeesFilterDialog> createState() => _MiscFeesFilterDialogState();
}

class _MiscFeesFilterDialogState extends State<MiscFeesFilterDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final MiscFeesController controller = Get.find();

  Map<String, String>? selectedClass;
  String? selectedMiscFeeType;
  String? selectedMonth;
  List<Map<String, String>> availableClasses = [];
  List<String> availableMiscFeeTypes = [
    'Library Fine',
    'Sports Fee',
    'Lab Maintenance',
    'Transportation',
    'Stationery',
    'Activity Fee',
    'Late Fee',
    'Other',
  ];
  List<String> availableMonths = [];
  bool isLoadingClasses = true;
  bool isLoadingMonths = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadAvailableClasses();
    _loadAvailableMonths();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableClasses() async {
    try {
      setState(() => isLoadingClasses = true);
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT DISTINCT class_name, section
        FROM students
        WHERE status = 'Active'
        ORDER BY class_name, section
      ''');

      setState(() {
        availableClasses = result
            .map(
              (row) => {
                'className': row['class_name'] as String,
                'section': row['section'] as String,
              },
            )
            .toList();
        isLoadingClasses = false;
      });
    } catch (e) {
      print('Error loading classes: $e');
      setState(() => isLoadingClasses = false);
      Get.snackbar('Error', 'Failed to load classes');
    }
  }

  Future<void> _loadAvailableMonths() async {
    try {
      setState(() => isLoadingMonths = true);

      // Always generate last 12 months as fallback/default
      final now = DateTime.now();
      final months = <String>[];
      for (int i = 0; i < 12; i++) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthName = _getMonthName(date.month);
        months.add('$monthName ${date.year}');
      }

      setState(() {
        availableMonths = months;
        isLoadingMonths = false;
      });

      // Try to get earliest month from database to extend the range if needed
      try {
        final db = await DatabaseService.database;
        final result = await db.rawQuery('''
          SELECT MIN(month) as earliest_month
          FROM misc_fees_pending
        ''');

        if (result.isNotEmpty && result.first['earliest_month'] != null) {
          final earliestMonthStr = result.first['earliest_month'] as String;
          // Parse the month string (format: "October 2025")
          final parts = earliestMonthStr.split(' ');
          if (parts.length == 2) {
            final monthName = parts[0];
            final year = int.tryParse(parts[1]);
            if (year != null) {
              final monthNumber = _getMonthNumber(monthName);
              if (monthNumber != null) {
                final earliestDate = DateTime(year, monthNumber);

                // If earliest date is before our generated months, extend the range
                final currentEarliest = DateTime(now.year, now.month - 11, 1);
                if (earliestDate.isBefore(currentEarliest)) {
                  final extendedMonths = <String>[];

                  var current = DateTime(earliestDate.year, earliestDate.month);
                  while (current.isBefore(DateTime(now.year, now.month + 1))) {
                    final monthName = _getMonthName(current.month);
                    extendedMonths.add('$monthName ${current.year}');
                    current = DateTime(current.year, current.month + 1);
                  }

                  setState(() {
                    availableMonths = extendedMonths.reversed
                        .toList(); // Most recent first
                  });
                }
              }
            }
          }
        }
      } catch (e) {
        // Database query failed, but we already have fallback months
        print('Database query for earliest month failed, using fallback: $e');
      }
    } catch (e) {
      print('Error loading months: $e');
      // Even if everything fails, provide some default months
      final now = DateTime.now();
      final fallbackMonths = <String>[];
      for (int i = 0; i < 12; i++) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthName = _getMonthName(date.month);
        fallbackMonths.add('$monthName ${date.year}');
      }
      setState(() {
        availableMonths = fallbackMonths;
        isLoadingMonths = false;
      });
      Get.snackbar('Error', 'Failed to load months');
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

  int? _getMonthNumber(String monthName) {
    const monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return monthMap[monthName];
  }

  bool get _isFormValid =>
      selectedClass != null ||
      selectedMiscFeeType != null ||
      selectedMonth != null;

  String _getClassDisplayName(Map<String, String> classData) {
    return '${classData['className']} ${classData['section']}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _closeDialog(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping dialog
                    child: Container(
                      width: MediaQuery.of(context).size.width > 600
                          ? 450.w
                          : 380.w,
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(24.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildClassDropdown(),
                                  SizedBox(height: 20.h),
                                  _buildMiscFeeTypeDropdown(),
                                  SizedBox(height: 20.h),
                                  _buildMonthDropdown(),
                                  SizedBox(height: 32.h),
                                  _buildFilterFeesButton(),
                                ],
                              ),
                            ),
                          ),
                          if (controller.isViewFiltered.value)
                            _buildResetFilterBar(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.filter_list,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Filter Misc Fees',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _closeDialog,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(Icons.close, color: Colors.grey[600], size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Class',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, String>>(
              value: selectedClass,
              hint: Text(
                'All Classes',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<Map<String, String>>(
                  value: null,
                  child: Text(
                    'All Classes',
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                ),
                ...availableClasses.map((classData) {
                  return DropdownMenuItem(
                    value: classData,
                    child: Text(
                      _getClassDisplayName(classData),
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                  );
                }),
              ],
              onChanged: isLoadingClasses
                  ? null
                  : (value) {
                      setState(() => selectedClass = value);
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiscFeeTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Misc Fee Type',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMiscFeeType,
              hint: Text(
                'All Fee Types',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'All Fee Types',
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                ),
                ...availableMiscFeeTypes.map((feeType) {
                  return DropdownMenuItem(
                    value: feeType,
                    child: Text(
                      feeType,
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => selectedMiscFeeType = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Month',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMonth,
              hint: Text(
                'All Months',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'All Months',
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                ),
                ...availableMonths.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(
                      month,
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => selectedMonth = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterFeesButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isFormValid ? _filterFees : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid ? AppColors.primary : Colors.grey[400],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: _isFormValid ? 2 : 0,
        ),
        child: Text(
          'Apply Filter',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _filterFees() async {
    if (selectedClass == null &&
        selectedMiscFeeType == null &&
        selectedMonth == null) {
      return;
    }

    // Debug logging
    print(
      "Filtering → Class: $selectedClass | Fee Type: $selectedMiscFeeType | Month: $selectedMonth",
    );

    // Extract class name and section
    final className = selectedClass?['className'] ?? '';
    final section = selectedClass?['section'] ?? '';
    final miscFeeType = selectedMiscFeeType ?? '';
    final month = selectedMonth ?? '';

    print("Query args: [$className, $miscFeeType, $month, $section]");

    // Close dialog first
    _closeDialog();

    // Then load filtered data
    await controller.viewFeesByClassAndTypeAndMonth(
      className,
      miscFeeType,
      month,
      section: section.isNotEmpty ? section : null,
    );
  }

  Widget _buildResetFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.blue[700], size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Showing fees for ${controller.selectedClass.value} - ${controller.selectedMiscFeeType.value} - ${controller.selectedMonth.value}',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              controller.clearViewFilter();
              _closeDialog();
            },
            icon: Icon(Icons.clear, size: 16.sp),
            label: Text(
              'Reset Filter',
              style: GoogleFonts.poppins(fontSize: 12.sp),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[700],
              padding: EdgeInsets.symmetric(horizontal: 8.w),
            ),
          ),
        ],
      ),
    );
  }

  void _closeDialog() {
    _animationController.reverse().then((_) {
      Get.back();
    });
  }
}
