import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/classes_controller.dart';
import '../controller/new_class_controller.dart';
import '../model/class_model.dart';
import 'new_class_view.dart';

class ClassesView extends GetView<ClassesController> {
  const ClassesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildClassesList()),
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
                  'Classes',
                  style: GoogleFonts.poppins(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // Search Bar
                Flexible(
                  child: Container(
                    width: 320.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Obx(
                      () => TextField(
                        controller:
                            TextEditingController(
                                text: controller.searchQuery.value,
                              )
                              ..selection = TextSelection.collapsed(
                                offset: controller.searchQuery.value.length,
                              ),
                        onChanged: controller.updateSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search classes...',
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
                SizedBox(width: 16.w),
                // New Admission Button
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: ElevatedButton.icon(
                        onPressed: () => _showNewClassDialog(Get.context!),
                        icon: Icon(Icons.add, size: 18.sp),
                        label: Text(
                          'Add New Class',
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

  Widget _buildClassesList() {
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
            'Loading classes...',
            style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Obx(() {
      final classes = controller.filteredClasses;
      print('ClassesView: Building DataTable with ${classes.length} classes');

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
                'Class Name',
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
                'Section',
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
                'Total Students',
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
          rows: classes.isEmpty
              ? []
              : List<DataRow2>.generate(classes.length, (index) {
                  final classItem = classes[index];
                  final isEvenRow = index % 2 == 0;

                  return DataRow2(
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
                          classItem.className,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          classItem.section,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: classItem.totalStudents > 0
                                ? AppColors.accent.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: classItem.totalStudents > 0
                                  ? AppColors.accent.withOpacity(0.3)
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${classItem.totalStudents}',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: classItem.totalStudents > 0
                                  ? AppColors.accent
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
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
                                onPressed: () =>
                                    controller.viewClass(classItem.id),
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      elevation: 0,
                                    ).copyWith(
                                      overlayColor:
                                          MaterialStateProperty.resolveWith<
                                            Color?
                                          >((states) {
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
                                onPressed: () =>
                                    _showEditClassDialog(classItem),
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                    ).copyWith(
                                      elevation:
                                          MaterialStateProperty.resolveWith<
                                            double
                                          >((states) {
                                            if (states.contains(
                                              MaterialState.hovered,
                                            )) {
                                              return 2;
                                            }
                                            return 1;
                                          }),
                                      overlayColor:
                                          MaterialStateProperty.resolveWith<
                                            Color?
                                          >((states) {
                                            if (states.contains(
                                              MaterialState.hovered,
                                            )) {
                                              return Colors.white.withOpacity(
                                                0.1,
                                              );
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
                                onPressed: () => _showDeleteConfirmationDialog(
                                  classItem.id,
                                  '${classItem.className} - ${classItem.section}',
                                ),
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                    ).copyWith(
                                      elevation:
                                          MaterialStateProperty.resolveWith<
                                            double
                                          >((states) {
                                            if (states.contains(
                                              MaterialState.hovered,
                                            )) {
                                              return 2;
                                            }
                                            return 1;
                                          }),
                                      overlayColor:
                                          MaterialStateProperty.resolveWith<
                                            Color?
                                          >((states) {
                                            if (states.contains(
                                              MaterialState.hovered,
                                            )) {
                                              return Colors.white.withOpacity(
                                                0.1,
                                              );
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
    });
  }

  void _showNewClassDialog(BuildContext context) {
    final controller = Get.put(NewClassController(), permanent: true);
    controller.resetForm(); // Ensure clean state for new class
    Get.dialog(const NewClassView(), barrierDismissible: false).then((_) {
      // Don't delete the controller here - let it persist
      // Get.delete<NewClassController>();
    });
  }

  void _showEditClassDialog(ClassModel classItem) {
    final controller = Get.put(NewClassController(), permanent: true);
    controller.setEditMode(classItem); // Pre-fill form with class data
    Get.dialog(const NewClassView(), barrierDismissible: false).then((_) {
      // Don't delete the controller here - let it persist
      // Get.delete<NewClassController>();
    });
  }

  void _showDeleteConfirmationDialog(int? classId, String classDisplayName) {
    if (classId == null) return;

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
                width: 320.w,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 30.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Title
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 50.0, end: 0.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: Opacity(
                            opacity: (50 - offset) / 50,
                            child: Text(
                              'Delete Class?',
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Message
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            'Are you sure you want to delete "$classDisplayName"?\n\nThis action cannot be undone.',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Buttons
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Row(
                            children: [
                              // Cancel button
                              Expanded(
                                child: SizedBox(
                                  height: 45.h,
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),

                              // Delete button
                              Expanded(
                                child: SizedBox(
                                  height: 45.h,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.back(); // Close confirmation dialog
                                      Get.find<ClassesController>().deleteClass(
                                        classId,
                                      ); // Delete the class
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
