import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/monthly_fees_controller.dart';
import 'monthly_pending_fees_view.dart';
import 'monthly_paid_fees_view.dart';

class MonthlyFeesView extends StatelessWidget {
  const MonthlyFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller if not already present
    final monthlyController = Get.put(MonthlyFeesController(), permanent: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildHeader(monthlyController),
          _buildSearchBar(monthlyController),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Pending Fees Section
                  Container(
                    margin: EdgeInsets.all(16.w),
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height *
                          0.3, // Minimum height
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.6, // Maximum height
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const MonthlyPendingFeesView(),
                  ),
                  SizedBox(height: 16.h), // Spacing between tables
                  // Paid Fees Section
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ).copyWith(bottom: 16.w),
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height *
                          0.3, // Minimum height
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.6, // Maximum height
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const MonthlyPaidFeesView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MonthlyFeesController monthlyController) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Monthly Fees Management',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showGenerateFeesDialog(),
            icon: Icon(Icons.add, size: 18.sp),
            label: Text(
              'Generate Monthly Fees',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A7BD5),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MonthlyFeesController monthlyController) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller:
                    TextEditingController(
                        text: monthlyController.searchQuery.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: monthlyController.searchQuery.value.length,
                      ),
                onChanged: monthlyController.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateFeesDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Generate Monthly Fees'),
        content: const Text(
          'This will generate monthly fee records for all active students for the current month. '
          'Only students without existing fees for this month will be processed.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Get.find<MonthlyFeesController>().generateMonthlyFees();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
