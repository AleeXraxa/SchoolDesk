import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/misc_fees_controller.dart';
import 'misc_pending_fees_view.dart';
import 'misc_paid_fees_view.dart';
import 'misc_fees_filter_dialog.dart';
import 'misc_generate_fees_dialog.dart';

class MiscFeesView extends StatelessWidget {
  const MiscFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller if not already present
    final miscController = Get.put(MiscFeesController(), permanent: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildHeader(miscController),
          _buildSearchBar(miscController),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Pending Fees Section
                  Container(
                    margin: EdgeInsets.all(16.w),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.3,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                    child: const MiscPendingFeesView(),
                  ),
                  SizedBox(height: 16.h),
                  // Paid Fees Section
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ).copyWith(bottom: 16.w),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.3,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                    child: const MiscPaidFeesView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MiscFeesController miscController) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Misc Fees Management',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showFilterDialog(),
                    icon: Icon(Icons.filter_list, size: 18.sp),
                    label: Text(
                      'Filter',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3A7BD5),
                      elevation: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: const BorderSide(
                          color: Color(0xFF3A7BD5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton.icon(
                    onPressed: () => _showGenerateFeesDialog(),
                    icon: Icon(Icons.add, size: 18.sp),
                    label: Text(
                      'Generate Misc Fees',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7BD5),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Show current filter info if filtered
          Obx(() {
            if (miscController.isViewFiltered.value) {
              return Container(
                margin: EdgeInsets.only(top: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Colors.blue[700],
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Showing fees for ${miscController.selectedClass.value} - ${miscController.selectedMiscFeeType.value} - ${miscController.selectedMonth.value}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => miscController.clearViewFilter(),
                      icon: Icon(Icons.clear, size: 16.sp),
                      label: Text(
                        'Clear Filter',
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
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MiscFeesController miscController) {
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
                        text: miscController.searchQuery.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: miscController.searchQuery.value.length,
                      ),
                onChanged: miscController.updateSearchQuery,
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

  void _showFilterDialog() {
    Get.dialog(const MiscFeesFilterDialog(), barrierDismissible: true);
  }

  void _showGenerateFeesDialog() {
    Get.dialog(const MiscGenerateFeesDialog(), barrierDismissible: true);
  }
}
