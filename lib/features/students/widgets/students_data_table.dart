import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/students_controller.dart';
import 'column_filter.dart';

class StudentsDataTable extends GetView<StudentsController> {
  const StudentsDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - opacity)),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                if (controller.filteredStudents.isEmpty) {
                  return Container(
                    height: 300.h,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: Colors.grey,
                          size: 48.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No students found',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Try adjusting your search or filters',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      AppColors.primary.withOpacity(0.05),
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.hovered)) {
                        return AppColors.primary.withOpacity(0.02);
                      }
                      return null;
                    }),
                    dataRowHeight: 60.h,
                    headingRowHeight: 50.h,
                    columnSpacing: 24.w,
                    horizontalMargin: 24.w,
                    columns: [
                      DataColumn(
                        label: ColumnFilter(column: 'rollNo', label: 'Roll No'),
                      ),
                      DataColumn(
                        label: ColumnFilter(
                          column: 'name',
                          label: 'Student Name',
                        ),
                      ),
                      DataColumn(
                        label: ColumnFilter(
                          column: 'fatherName',
                          label: 'Father\'s Name',
                        ),
                      ),
                      DataColumn(
                        label: ColumnFilter(column: 'class', label: 'Class'),
                      ),
                      DataColumn(
                        label: ColumnFilter(
                          column: 'contact',
                          label: 'Contact',
                        ),
                      ),
                      DataColumn(
                        label: ColumnFilter(column: 'status', label: 'Status'),
                      ),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: controller.filteredStudents.isEmpty
                        ? []
                        : controller.filteredStudents.map((student) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    student.rollNo,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student.studentName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student.fatherName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
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
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        student.status,
                                      ).withOpacity(0.1),
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
                                    children: [
                                      IconButton(
                                        onPressed: () => controller.viewStudent(
                                          student.rollNo,
                                        ),
                                        icon: Icon(
                                          Icons.visibility,
                                          color: Colors.blue,
                                          size: 18.sp,
                                        ),
                                        tooltip: 'View Details',
                                      ),
                                      IconButton(
                                        onPressed: () => controller.editStudent(
                                          student.rollNo,
                                        ),
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                          size: 18.sp,
                                        ),
                                        tooltip: 'Edit Student',
                                      ),
                                      IconButton(
                                        onPressed: () => controller
                                            .deleteStudent(student.id!),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18.sp,
                                        ),
                                        tooltip: 'Delete Student',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
}
