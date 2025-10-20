import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database_service.dart';
import '../controller/monthly_fees_controller.dart';

class ViewFeesDialog extends StatefulWidget {
  const ViewFeesDialog({super.key});

  @override
  State<ViewFeesDialog> createState() => _ViewFeesDialogState();
}

class _ViewFeesDialogState extends State<ViewFeesDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final MonthlyFeesController controller = Get.find();

  Map<String, String>? selectedClass; // {className: "Class 1", section: "A"}
  String? selectedMonth;
  List<Map<String, String>> availableClasses =
      []; // [{className: "Class 1", section: "A"}]
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
      final db = await DatabaseService.database;

      // Get the earliest month from monthly_fees table
      final result = await db.rawQuery('''
        SELECT MIN(month) as earliest_month
        FROM monthly_fees
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

              // Generate months from earliest to current
              final now = DateTime.now();
              final months = <String>[];

              var current = DateTime(earliestDate.year, earliestDate.month);
              while (current.isBefore(DateTime(now.year, now.month + 1))) {
                final monthName = _getMonthName(current.month);
                months.add('$monthName ${current.year}');
                current = DateTime(current.year, current.month + 1);
              }

              setState(() {
                availableMonths = months.reversed.toList(); // Most recent first
                isLoadingMonths = false;
              });
              return;
            }
          }
        }
      } else {
        // Fallback: generate last 12 months if no data exists
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
      }
    } catch (e) {
      print('Error loading months: $e');
      setState(() => isLoadingMonths = false);
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

  bool get _isFormValid => selectedClass != null && selectedMonth != null;

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
                          ? 400.w
                          : 320.w,
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                                  _buildMonthDropdown(),
                                  SizedBox(height: 32.h),
                                  _buildViewFeesButton(),
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
              Icons.visibility,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'View Monthly Fees',
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
                'Choose a class',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              isExpanded: true,
              items: isLoadingClasses
                  ? [
                      DropdownMenuItem(
                        value: null,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Loading classes...',
                              style: GoogleFonts.poppins(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : availableClasses.map((classData) {
                      return DropdownMenuItem(
                        value: classData,
                        child: Text(
                          _getClassDisplayName(classData),
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
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
                'Choose a month',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              isExpanded: true,
              items: isLoadingMonths
                  ? [
                      DropdownMenuItem(
                        value: null,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Loading months...',
                              style: GoogleFonts.poppins(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : availableMonths.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          month,
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
              onChanged: isLoadingMonths
                  ? null
                  : (value) {
                      setState(() => selectedMonth = value);
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewFeesButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isFormValid ? _viewFees : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid ? AppColors.primary : Colors.grey[400],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: _isFormValid ? 2 : 0,
        ),
        child: Text(
          'View Fees',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _viewFees() async {
    if (selectedClass == null || selectedMonth == null) return;

    // Debug logging
    print(
      "Selected Class: ${selectedClass!['className']} - Section: ${selectedClass!['section']}",
    );
    print("Selected Month: $selectedMonth");

    // Close dialog first
    _closeDialog();

    // Then load filtered data
    await controller.viewFeesByClassAndMonth(
      selectedClass!['className']!,
      selectedMonth!,
      section: selectedClass!['section']!,
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
              'Showing fees for ${controller.selectedClass.value} - ${controller.selectedMonth.value}',
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
