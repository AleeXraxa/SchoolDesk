import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/challan_controller.dart';
import 'admission_challan_view.dart';
import 'monthly_challan_view.dart';
import 'exam_challan_view.dart';
import 'misc_challan_view.dart';

class ChallanView extends GetView<ChallanController> {
  const ChallanView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChallanController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Text(
            'Challan Management',
            style: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          _buildSectionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionButtons() {
    return Obx(
      () => Row(
        children: ChallanSection.values.map((section) {
          final isSelected = controller.selectedSection.value == section;
          return Container(
            margin: EdgeInsets.only(left: 12.w),
            child: ElevatedButton(
              onPressed: () => controller.changeSection(section),
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : Colors.grey[100],
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    elevation: isSelected ? 2 : 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    shadowColor: isSelected
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.transparent,
                  ).copyWith(
                    elevation: MaterialStateProperty.resolveWith<double>((
                      states,
                    ) {
                      if (states.contains(MaterialState.hovered) &&
                          isSelected) {
                        return 4;
                      }
                      return isSelected ? 2 : 0;
                    }),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(MaterialState.hovered)) {
                        return isSelected
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200];
                      }
                      return null;
                    }),
                  ),
              child: Text(
                _getSectionTitle(section),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
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
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildCurrentSection(),
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (controller.selectedSection.value) {
      case ChallanSection.admissionChallans:
        return const AdmissionChallanView(key: ValueKey('admission'));
      case ChallanSection.monthlyChallans:
        return const MonthlyChallanView(key: ValueKey('monthly'));
      case ChallanSection.examChallans:
        return const ExamChallanView(key: ValueKey('exam'));
      case ChallanSection.miscChallans:
        return const MiscChallanView(key: ValueKey('misc'));
      case ChallanSection.multipleChallans:
        return const MiscChallanView(
          key: ValueKey('multiple'),
        ); // Reuse MiscChallanView for now
    }
  }

  String _getSectionTitle(ChallanSection section) {
    switch (section) {
      case ChallanSection.admissionChallans:
        return 'Admission Challans';
      case ChallanSection.monthlyChallans:
        return 'Monthly Challans';
      case ChallanSection.examChallans:
        return 'Exam Challans';
      case ChallanSection.miscChallans:
        return 'Misc Challans';
      case ChallanSection.multipleChallans:
        return 'Multiple Challans';
    }
  }
}

class ChallanMainView extends GetView<ChallanController> {
  const ChallanMainView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChallanController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Text(
            'Challan Management',
            style: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          _buildSectionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionButtons() {
    return Obx(
      () => Row(
        children: ChallanSection.values.map((section) {
          final isSelected = controller.selectedSection.value == section;
          return Container(
            margin: EdgeInsets.only(left: 12.w),
            child: ElevatedButton(
              onPressed: () => controller.changeSection(section),
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : Colors.grey[100],
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    elevation: isSelected ? 2 : 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    shadowColor: isSelected
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.transparent,
                  ).copyWith(
                    elevation: MaterialStateProperty.resolveWith<double>((
                      states,
                    ) {
                      if (states.contains(MaterialState.hovered) &&
                          isSelected) {
                        return 4;
                      }
                      return isSelected ? 2 : 0;
                    }),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(MaterialState.hovered)) {
                        return isSelected
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200];
                      }
                      return null;
                    }),
                  ),
              child: Text(
                _getSectionTitle(section),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
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
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildCurrentSection(),
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (controller.selectedSection.value) {
      case ChallanSection.admissionChallans:
        return const AdmissionChallanView(key: ValueKey('admission'));
      case ChallanSection.monthlyChallans:
        return const MonthlyChallanView(key: ValueKey('monthly'));
      case ChallanSection.examChallans:
        return const ExamChallanView(key: ValueKey('exam'));
      case ChallanSection.miscChallans:
        return const MiscChallanView(key: ValueKey('misc'));
      case ChallanSection.multipleChallans:
        return const MiscChallanView(
          key: ValueKey('multiple'),
        ); // Reuse MiscChallanView for now
    }
  }

  String _getSectionTitle(ChallanSection section) {
    switch (section) {
      case ChallanSection.admissionChallans:
        return 'Admission Challans';
      case ChallanSection.monthlyChallans:
        return 'Monthly Challans';
      case ChallanSection.examChallans:
        return 'Exam Challans';
      case ChallanSection.miscChallans:
        return 'Misc Challans';
      case ChallanSection.multipleChallans:
        return 'Multiple Challans';
    }
  }
}
