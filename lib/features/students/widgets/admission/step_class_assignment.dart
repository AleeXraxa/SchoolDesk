import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/new_admission_controller.dart';
import 'custom_dropdown.dart';

class StepClassAssignment extends GetView<NewAdmissionController> {
  const StepClassAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.classAssignmentFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.class_, color: Colors.blue, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Assignment',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Assign the student to a class and section',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Loading state for classes
            Obx(() {
              if (controller.isLoadingClasses.value) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading classes...',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.classOptions.isEmpty) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.class_outlined,
                        color: Colors.grey,
                        size: 48.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No classes available',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Please add classes in the Classes section first',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Class Selection
                  CustomDropdown(
                    label: 'Class',
                    selectedValue: controller.selectedClass,
                    options: controller.classOptions,
                    icon: Icons.class_,
                    placeholder: 'Select Class',
                    onChanged: controller.onClassChanged,
                    validator: (value) =>
                        controller.validateRequired(value, 'Class'),
                  ),
                  SizedBox(height: 16.h),

                  // Section Selection
                  Obx(() {
                    final isSectionEnabled =
                        controller.selectedClass.value.isNotEmpty;
                    return CustomDropdown(
                      label: 'Section',
                      selectedValue: controller.selectedSection,
                      options: controller.sectionOptions,
                      icon: Icons.group,
                      placeholder: isSectionEnabled
                          ? 'Select Section'
                          : 'Select a class first',
                      onChanged: controller.onSectionChanged,
                      validator: (value) =>
                          controller.validateRequired(value, 'Section'),
                    );
                  }),
                ],
              );
            }),
            SizedBox(height: 24.h),

            // Preview Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Assignment Preview',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: 'Student will be assigned to '),
                          TextSpan(
                            text:
                                '${controller.selectedClass.value} - ${controller.selectedSection.value}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                          const TextSpan(text: ' class.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
