import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/result_dialog.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/sidebar/sidebar_widget.dart';
import '../widgets/sidebar/sidebar_controller.dart';
import '../../students/view/students_view.dart';
import '../../students/controller/students_controller.dart';
import '../../classes/view/classes_view.dart';
import '../../classes/controller/classes_controller.dart';
import '../../fees/view/fees_view.dart';
import '../../fees/controller/fees_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize sidebar controller if not already
    if (!Get.isRegistered<SidebarController>()) {
      Get.put(SidebarController());
    }

    // Initialize students controller for the students section
    if (!Get.isRegistered<StudentsController>()) {
      Get.put(StudentsController());
    }

    // Initialize classes controller for the classes section
    if (!Get.isRegistered<ClassesController>()) {
      Get.put(ClassesController());
    }

    // Initialize fees controller for the fees section
    if (!Get.isRegistered<FeesController>()) {
      Get.put(FeesController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Row(
        children: [
          // Sidebar Widget
          const SidebarWidget(),

          // Main Content
          Expanded(
            child: Obx(() {
              final sidebarController = Get.find<SidebarController>();
              return _buildMainContent(sidebarController.selectedIndex.value);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0: // Dashboard/Home
        return Column(
          children: [
            // Header Bar
            _buildHeaderBar(),
            // Main Body Content
            Expanded(child: _buildMainBody()),
          ],
        );
      case 1: // Students
        return StudentsView();
      case 2: // Classes
        return ClassesView();
      case 3: // Fees
        return FeesView();
      default: // Default to dashboard
        return Column(
          children: [
            // Header Bar
            _buildHeaderBar(),
            // Main Body Content
            Expanded(child: _buildMainBody()),
          ],
        );
    }
  }

  Widget _buildHeaderBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            height: 70.h,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // App Name
                Text(
                  'SchoolDesk',
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const Spacer(),

                // Logout Button
                ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(Get.context!),
                  icon: Icon(Icons.logout, size: 18.sp),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[700],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainBody() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            color: const Color(0xFFF8FAFD),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome Icon
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.dashboard,
                      color: Colors.white,
                      size: 60.sp,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Welcome Text
                  Text(
                    'Welcome to SchoolDesk Admin Dashboard 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16.h),

                  // Subtitle
                  Text(
                    'Manage your school\'s data efficiently and effectively',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),

                  // Quick Stats Preview
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Quick Overview',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickStat('1,250', 'Students'),
                            _buildQuickStat('45', 'Teachers'),
                            _buildQuickStat('32', 'Classes'),
                            _buildQuickStat('87.5%', 'Attendance'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54),
        ),
      ],
    );
  }

  void _handleLogout() {
    ResultDialog.showError(
      Get.context!,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );
    // Note: ResultDialog.showError returns void, so we can't chain .then()
    // For now, just call logout directly. In a real app, you'd create a custom confirmation dialog
    Future.delayed(const Duration(seconds: 2), () {
      controller.logout();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    ResultDialog.showError(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );
    // Note: ResultDialog.showError returns void, so we can't chain .then()
    // For now, just call logout directly. In a real app, you'd create a custom confirmation dialog
    Future.delayed(const Duration(seconds: 2), () {
      controller.logout();
    });
  }
}
