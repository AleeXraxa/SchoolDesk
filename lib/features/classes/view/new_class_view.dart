import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/new_class_controller.dart';

class NewClassView extends GetView<NewClassController> {
  const NewClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500.w,
        constraints: BoxConstraints(maxHeight: 600.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
                child: Obx(() => _buildStepContent()),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.class_, color: Colors.white, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.getStepTitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.getStepSubtitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(
      () => Row(
        children: List.generate(controller.totalSteps, (index) {
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: index <= controller.currentStep.value
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: index <= controller.currentStep.value
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                if (index < controller.totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: index < controller.currentStep.value
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildClassNameStep();
      case 1:
        return _buildSectionStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildClassNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class Name',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: TextEditingController(text: controller.className.value)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: controller.className.value.length),
              ),
            onChanged: (value) => controller.className.value = value,
            decoration: InputDecoration(
              hintText: 'e.g., Class 1, Grade 10, Nursery',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorText: controller.classNameError.value.isNotEmpty
                  ? controller.classNameError.value
                  : null,
              errorStyle: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Section',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: TextEditingController(text: controller.section.value)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: controller.section.value.length),
              ),
            onChanged: (value) =>
                controller.section.value = value.toUpperCase(),
            maxLength: 1,
            decoration: InputDecoration(
              hintText: 'e.g., A, B, C',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorText: controller.sectionError.value.isNotEmpty
                  ? controller.sectionError.value
                  : null,
              errorStyle: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14.sp),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Information',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildReviewItem('Class Name', controller.className.value),
              SizedBox(height: 12.h),
              _buildReviewItem(
                'Section',
                controller.section.value.toUpperCase(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        child: Row(
          children: [
            if (!controller.isFirstStep)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            if (!controller.isFirstStep) SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : (controller.isLastStep
                          ? controller.submitForm
                          : controller.nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Obx(
                        () => Text(
                          controller.isLastStep
                              ? (controller.isEditing.value
                                    ? 'Update Class'
                                    : 'Create Class')
                              : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
