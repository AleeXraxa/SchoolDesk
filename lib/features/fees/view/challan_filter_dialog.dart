import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallanFilterDialog extends StatelessWidget {
  const ChallanFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // ChallanController removed - show dummy filter dialog
    final controller = null;

    return Dialog(
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
              width: MediaQuery.of(context).size.width > 600 ? 500.w : 450.w,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
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
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: Colors.blue[600],
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Filter Challans',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Filter Form
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Class Filter
                          Text(
                            'Class',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedClass.value.isNotEmpty
                                  ? controller.selectedClass.value
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Select class',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.class_,
                                  color: Colors.blue[600],
                                  size: 20.sp,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              items:
                                  [
                                    'Class 1',
                                    'Class 2',
                                    'Class 3',
                                    'Class 4',
                                    'Class 5',
                                    'Class 6',
                                    'Class 7',
                                    'Class 8',
                                    'Class 9',
                                    'Class 10',
                                  ].map((className) {
                                    return DropdownMenuItem(
                                      value: className,
                                      child: Text(
                                        className,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                controller.selectedClass.value = value ?? '';
                              },
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Section Filter
                          Text(
                            'Section',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedSection.value.isNotEmpty
                                  ? controller.selectedSection.value
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Select section',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.group,
                                  color: Colors.blue[600],
                                  size: 20.sp,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              items: ['A', 'B', 'C', 'D', 'E', 'F'].map((
                                section,
                              ) {
                                return DropdownMenuItem(
                                  value: section,
                                  child: Text(
                                    section,
                                    style: GoogleFonts.inter(fontSize: 14.sp),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                controller.selectedSection.value = value ?? '';
                              },
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Month Filter
                          Text(
                            'Month',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedMonth.value.isNotEmpty
                                  ? controller.selectedMonth.value
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Select month',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.calendar_month,
                                  color: Colors.blue[600],
                                  size: 20.sp,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              items:
                                  [
                                    'January 2025',
                                    'February 2025',
                                    'March 2025',
                                    'April 2025',
                                    'May 2025',
                                    'June 2025',
                                    'July 2025',
                                    'August 2025',
                                    'September 2025',
                                    'October 2025',
                                    'November 2025',
                                    'December 2025',
                                  ].map((month) {
                                    return DropdownMenuItem(
                                      value: month,
                                      child: Text(
                                        month,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                controller.selectedMonth.value = value ?? '';
                              },
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Fee Type Filter
                          Text(
                            'Fee Type',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedFeeType.value.isNotEmpty
                                  ? controller.selectedFeeType.value
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Select fee type',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: Colors.blue[600],
                                  size: 20.sp,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              items:
                                  [
                                    'Admission',
                                    'Monthly',
                                    'Exam',
                                    'Misc',
                                    'Combined',
                                  ].map((feeType) {
                                    return DropdownMenuItem(
                                      value: feeType,
                                      child: Text(
                                        feeType,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                controller.selectedFeeType.value = value ?? '';
                              },
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Status Filter
                          Text(
                            'Status',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedStatus.value.isNotEmpty
                                  ? controller.selectedStatus.value
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Select status',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.info,
                                  color: Colors.blue[600],
                                  size: 20.sp,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              items: ['Generated', 'Paid', 'Cancelled'].map((
                                status,
                              ) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: GoogleFonts.inter(fontSize: 14.sp),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                controller.selectedStatus.value = value ?? '';
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.clearFilters();
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            child: Text(
                              'Clear All',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.loadChallansByFilters();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shadowColor: Colors.blue.withOpacity(0.3),
                            ),
                            child: Text(
                              'Apply Filters',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
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
            ),
          );
        },
      ),
    );
  }
}
