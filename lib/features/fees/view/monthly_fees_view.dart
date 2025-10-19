import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/fees_controller.dart';
import 'pending_fees_view.dart';
import 'paid_fees_view.dart';

class MonthlyFeesView extends GetView<FeesController> {
  const MonthlyFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: Row(
            children: [
              // Pending Fees Section
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.w),
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
                  child: const PendingFeesView(),
                ),
              ),
              // Paid Fees Section
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.w),
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
                  child: const PaidFeesView(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
              child: Obx(
                () => TextField(
                  controller:
                      TextEditingController(text: controller.searchQuery.value)
                        ..selection = TextSelection.collapsed(
                          offset: controller.searchQuery.value.length,
                        ),
                  onChanged: controller.updateSearchQuery,
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
          ),
        ],
      ),
    );
  }
}
