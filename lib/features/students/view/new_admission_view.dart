import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/new_admission_controller.dart';
import '../widgets/admission/step_personal_details.dart';
import '../widgets/admission/step_class_assignment.dart';
import '../widgets/admission/step_fees_amount.dart';
import '../widgets/admission/step_review_confirm.dart';

class NewAdmissionView extends StatefulWidget {
  const NewAdmissionView({super.key});

  @override
  State<NewAdmissionView> createState() => _NewAdmissionViewState();
}

class _NewAdmissionViewState extends State<NewAdmissionView> {
  late NewAdmissionController controller;
  final Map<int, Widget> _formWidgets = {};

  @override
  void initState() {
    super.initState();
    controller = Get.find<NewAdmissionController>();
    // Pre-create all form widgets to ensure they maintain state
    _initializeFormWidgets();
  }

  void _initializeFormWidgets() {
    _formWidgets[0] = StepPersonalDetails(
      key: const ValueKey('personal_details'),
    );
    _formWidgets[1] = StepClassAssignment(
      key: const ValueKey('class_assignment'),
    );
    _formWidgets[2] = StepFeesAmount(key: const ValueKey('fees_amount'));
    _formWidgets[3] = StepReviewConfirm(key: const ValueKey('review_confirm'));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800.w,
        height: 700.h,
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
          children: [
            // Header
            _buildHeader(),
            // Progress Indicator
            _buildProgressIndicator(),
            // Content
            Expanded(child: _buildContent()),
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.person_add, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.isEditMode.value
                        ? 'Edit Student'
                        : 'New Student Admission',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    controller.isEditMode.value
                        ? 'Update student information'
                        : 'Complete the 4-step process to add a new student',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(
        () => Row(
          children: List.generate(controller.totalSteps, (index) {
            final isActive = index == controller.currentStep.value;
            final isCompleted = index < controller.currentStep.value;

            return Expanded(
              child: Row(
                children: [
                  // Step Circle
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : isActive
                          ? AppColors.primary
                          : Colors.grey.withOpacity(0.3),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  // Connector Line
                  if (index < controller.totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2.h,
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(
      () => IndexedStack(
        index: controller.currentStep.value,
        children: [
          StepPersonalDetails(),
          StepClassAssignment(),
          StepFeesAmount(),
          StepReviewConfirm(),
        ],
      ),
    );
  }

  Widget _getCurrentStepWidget() {
    print(
      'NewAdmissionView: Getting widget for step ${controller.currentStep.value}',
    );
    // Return the pre-created widget for the current step
    return _formWidgets[controller.currentStep.value] ??
        StepPersonalDetails(key: const ValueKey('personal_details_default'));
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            // Back Button
            if (controller.currentStep.value > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              )
            else
              const Spacer(),

            if (controller.currentStep.value > 0) SizedBox(width: 12.w),

            // Next/Submit Button
            Expanded(
              child: ElevatedButton(
                onPressed:
                    controller.currentStep.value == controller.totalSteps - 1
                    ? controller.submitAdmission
                    : controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      controller.currentStep.value == controller.totalSteps - 1
                      ? Colors.green
                      : AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Obx(
                  () => Text(
                    controller.currentStep.value == controller.totalSteps - 1
                        ? (controller.isEditMode.value
                              ? 'Update Student'
                              : 'Confirm & Submit')
                        : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
