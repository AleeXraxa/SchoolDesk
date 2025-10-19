import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/fees_controller.dart';

class ExamFeesView extends GetView<FeesController> {
  const ExamFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildFeesTable()),
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

  Widget _buildFeesTable() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final students = controller.getFilteredStudents();

      if (students.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'No students found',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Header Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Student Name',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Class',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Exam Type',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Students List
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isEvenRow = index % 2 == 0;
                final examTypes = ['Mid-term', 'Final', 'Unit Test'];
                final examType = examTypes[index % examTypes.length];
                final amount = examType == 'Mid-term'
                    ? 500
                    : examType == 'Final'
                    ? 1000
                    : 200;
                final isPaid = index % 3 != 0; // Some are unpaid

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  color: isEvenRow ? Colors.grey[25] : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          student.studentName,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${student.className} - ${student.section}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          examType,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Rs. $amount',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            isPaid ? 'Paid' : 'Pending',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: isPaid
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.visibility, size: 18.sp),
                              tooltip: 'View Details',
                              color: Colors.blue[600],
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.payment, size: 18.sp),
                              tooltip: 'Pay Fee',
                              color: isPaid
                                  ? Colors.green[600]
                                  : Colors.orange[600],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
