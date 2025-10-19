import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/students_controller.dart';
import '../controller/new_admission_controller.dart';
import 'new_admission_view.dart';

class StudentsView extends GetView<StudentsController> {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildStudentsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            height: 100.h,
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Title
                Text(
                  'Students',
                  style: GoogleFonts.poppins(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Bulk Insert Button
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.bulkInsertSampleStudents(),
                        icon: Icon(Icons.add_circle, size: 18.sp),
                        label: Text(
                          'Add 100 Sample Students',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: EdgeInsets.symmetric(
                                horizontal: 28.w,
                                vertical: 14.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              shadowColor: Colors.green[200],
                            ).copyWith(
                              elevation:
                                  MaterialStateProperty.resolveWith<double>((
                                    Set<MaterialState> states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return 4;
                                    }
                                    return 2;
                                  }),
                            ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 16.w),
                // New Admission Button
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: ElevatedButton.icon(
                        onPressed: () => _showNewAdmissionDialog(Get.context!),
                        icon: Icon(Icons.add, size: 18.sp),
                        label: Text(
                          'New Admission',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: EdgeInsets.symmetric(
                                horizontal: 28.w,
                                vertical: 14.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              shadowColor: AppColors.primary.withOpacity(0.3),
                            ).copyWith(
                              elevation:
                                  MaterialStateProperty.resolveWith<double>((
                                    Set<MaterialState> states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return 4;
                                    }
                                    return 2;
                                  }),
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
    );
  }

  Widget _buildStudentsList() {
    return Container(
      margin: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return SizedBox(height: 400.h, child: _buildLoadingState());
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, opacity, child) {
            return Opacity(opacity: opacity, child: _buildDataTable());
          },
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading students...',
            style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SizedBox(
      height: MediaQuery.of(Get.context!).size.height - 200.h,
      child: DataTable2(
        columnSpacing: 8.w,
        horizontalMargin: 8.w,
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        headingRowHeight: 56.h,
        dataRowHeight: 60.h,
        showCheckboxColumn: false,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        columns: [
          DataColumn2(
            label: Text(
              'Roll No',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(
              'Student Name',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text(
              'Father\'s Name',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text(
              'Class',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(
              'Contact',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(
              'Status',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(
              'Actions',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            size: ColumnSize.L,
          ),
        ],
        rows: List<DataRow>.generate(controller.filteredStudents.length, (
          index,
        ) {
          final student = controller.filteredStudents[index];
          final isEvenRow = index % 2 == 0;

          return DataRow(
            color: MaterialStateProperty.resolveWith<Color?>((
              Set<MaterialState> states,
            ) {
              if (states.contains(MaterialState.hovered)) {
                return AppColors.primary.withOpacity(0.05);
              }
              return isEvenRow ? Colors.grey[50] : Colors.white;
            }),
            cells: [
              DataCell(
                Text(
                  student.rollNo,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Text(
                  student.studentName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Text(
                  student.fatherName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${student.className} - ${student.section}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  student.fatherContact,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(student.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    student.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(student.status),
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // View Button
                    SizedBox(
                      width: 80.w,
                      height: 32.h,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.viewStudent(student.rollNo),
                        icon: Icon(Icons.visibility, size: 16.sp),
                        label: Text(
                          'View',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style:
                            OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                              side: BorderSide(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                              backgroundColor: Colors.blue[50],
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              elevation: 0,
                            ).copyWith(
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return Colors.blue[100];
                                    }
                                    return null;
                                  }),
                            ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    // Edit Button
                    SizedBox(
                      width: 70.w,
                      height: 32.h,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.editStudent(student.rollNo),
                        icon: Icon(Icons.edit, size: 14.sp),
                        label: Text(
                          'Edit',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shadowColor: Colors.orange[200],
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ).copyWith(
                              elevation:
                                  MaterialStateProperty.resolveWith<double>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return 2;
                                    }
                                    return 1;
                                  }),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return Colors.white.withOpacity(0.1);
                                    }
                                    return null;
                                  }),
                            ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    // Delete Button
                    SizedBox(
                      width: 80.w,
                      height: 32.h,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.deleteStudent(student.id!),
                        icon: Icon(Icons.delete, size: 14.sp),
                        label: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shadowColor: Colors.red[200],
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ).copyWith(
                              elevation:
                                  MaterialStateProperty.resolveWith<double>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return 2;
                                    }
                                    return 1;
                                  }),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return Colors.white.withOpacity(0.1);
                                    }
                                    return null;
                                  }),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showNewAdmissionDialog(BuildContext context) {
    Get.put(NewAdmissionController(), permanent: true);
    Get.dialog(const NewAdmissionView(), barrierDismissible: false).then((_) {
      // Don't delete the controller here - let it persist
      // Get.delete<NewAdmissionController>();
    });
  }
}
