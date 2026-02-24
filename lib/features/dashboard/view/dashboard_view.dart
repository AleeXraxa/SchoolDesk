import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/result_dialog.dart';
import '../../../widgets/footer_widget.dart';
import '../../../widgets/birthday_notifications_dialog.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/sidebar/sidebar_widget.dart';
import '../widgets/sidebar/sidebar_controller.dart';
import '../../students/view/students_view.dart';
import '../../students/controller/students_controller.dart';
import '../../classes/view/classes_view.dart';
import '../../classes/controller/classes_controller.dart';
import '../../fees/view/fees_view.dart';
import '../../fees/controller/fees_controller.dart';
import '../../fees/view/challan_view.dart';
import '../../fees/controller/challan_controller.dart';
import '../../users/view/users_view.dart';
import '../../users/controller/users_controller.dart';
import '../../expenses/view/expenses_view.dart';

class DashboardView extends GetView<DashboardController> {
  DashboardView({super.key});

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

    // Initialize challan controller for the challan section
    if (!Get.isRegistered<ChallanController>()) {
      Get.put(ChallanController());
    }

    // Initialize users controller for the users section
    if (!Get.isRegistered<UsersController>()) {
      Get.put(UsersController());
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
            // Footer
            const FooterWidget(),
          ],
        );
      case 1: // Students
        return StudentsView();
      case 2: // Classes
        return ClassesView();
      case 3: // Fees
        return FeesView();
      case 4: // Challans
        return ChallanView();
      case 5: // Expenses
        return ExpensesView();
      case 6: // Users
        return UsersView();
      default: // Default to dashboard
        return Column(
          children: [
            // Header Bar
            _buildHeaderBar(),
            // Main Body Content
            Expanded(child: _buildMainBody()),
            // Footer
            const FooterWidget(),
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

                // Refresh Button
                StatefulBuilder(
                  builder: (context, setState) {
                    double _scale = 1.0;
                    return MouseRegion(
                      onEnter: (_) => setState(() => _scale = 1.05),
                      onExit: (_) => setState(() => _scale = 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()..scale(_scale),
                        child: ElevatedButton.icon(
                          onPressed: () => controller.loadDashboardStats(),
                          icon: Icon(Icons.refresh, size: 18.sp),
                          label: Text(
                            'Refresh',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            foregroundColor: AppColors.primary,
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
                      ),
                    );
                  },
                ),
                SizedBox(width: 12.w),

                // Bell Icon Button
                StatefulBuilder(
                  builder: (context, setState) {
                    double _scale = 1.0;
                    return MouseRegion(
                      onEnter: (_) => setState(() => _scale = 1.05),
                      onExit: (_) => setState(() => _scale = 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()..scale(_scale),
                        child: IconButton(
                          onPressed: () => Get.dialog(
                            const BirthdayNotificationsDialog(),
                            barrierDismissible: true,
                          ),
                          icon: Icon(Icons.notifications_none, size: 24.sp),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 1,
                            padding: EdgeInsets.all(12.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          tooltip: 'Birthday Notifications',
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 12.w),

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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Quick Stats Section
                  _buildQuickStatsSection(),

                  // Monthly Revenue Overview Section
                  _buildMonthlyRevenueOverview(),
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

  Widget _buildQuickStatsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStatsHeader(),
          SizedBox(height: 20.h),
          _buildQuickStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildQuickStatsHeader() {
    return Row(
      children: [
        Text(
          "Quick Stats",
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 10.w),
        Icon(Icons.speed_rounded, color: Colors.blueAccent, size: 24.sp),
      ],
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      childAspectRatio: 1.5,
      crossAxisCount: 3,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 10.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          Icons.people,
          "Active Students",
          "Total currently enrolled",
          controller.activeStudentsCount.value.toString(),
          LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        Obx(
          () => _buildStatCard(
            Icons.done,
            "Paid Monthly Fees",
            "Fully paid fees",
            controller.countPaidMonthlyFees.value.toString(),
            LinearGradient(
              colors: [Colors.green.shade300, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Obx(
          () => _buildStatCard(
            Icons.pending,
            "Monthly Fees Pending",
            "Partial/pending fee payments",
            controller.monthlyFeesPending.value.toString(),
            LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Obx(
          () => _buildStatCard(
            Icons.add,
            "Total Admissions",
            "Total students enrolled",
            controller.admissionsThisMonth.value.toString(),
            LinearGradient(
              colors: [Colors.green.shade300, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Obx(
          () => _buildStatCard(
            Icons.trending_up,
            "Total Revenue",
            "All fees collected",
            "PKR ${controller.totalRevenueThisMonth.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            LinearGradient(
              colors: [Colors.teal.shade300, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Obx(
          () => _buildStatCard(
            Icons.trending_down,
            "Total Expenses (Current Month)",
            "Monthly expenses incurred",
            "PKR ${controller.totalExpensesThisMonth.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            LinearGradient(
              colors: [Colors.red.shade300, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String subtitle,
    String value,
    LinearGradient gradient,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        double _scale = 1.0;
        return MouseRegion(
          onEnter: (_) => setState(() => _scale = 1.03),
          onExit: (_) => setState(() => _scale = 1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_scale),
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 40.sp),
                  SizedBox(height: 10.h),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Future<void> _downloadRevenueReport(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Load logo image
      final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/Logo.jpeg')).buffer.asUint8List(),
      );

      // Get revenue data
      final revenueMap = controller.dailyRevenue;
      final selectedMonth = controller.selectedMonth.value;
      final collectedEntries =
          revenueMap.entries
              .where(
                (entry) => entry.key >= 1 && entry.key <= 31 && entry.value > 0,
              )
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      final invalidDateTotal = revenueMap.entries
          .where((entry) => (entry.key < 1 || entry.key > 31) && entry.value > 0)
          .fold<double>(0.0, (sum, entry) => sum + entry.value);
      final List<pw.TableRow> revenueRows = collectedEntries.isEmpty
          ? [
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('No collections found'),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('0'),
                  ),
                ],
              ),
            ]
          : collectedEntries.map((entry) {
              final day = entry.key;
              final revenue = entry.value;
              final revenueStr = revenue
                  .toStringAsFixed(0)
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  );

              return pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${day.toString().padLeft(2, '0')} $selectedMonth',
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(revenueStr),
                  ),
                ],
              );
            }).toList();
      if (invalidDateTotal > 0) {
        final invalidRevenueStr = invalidDateTotal
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
        revenueRows.add(
          pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Unknown Date'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(invalidRevenueStr),
              ),
            ],
          ),
        );
      }

      // Calculate total
      double total = revenueMap.values.fold(0.0, (sum, amount) => sum + amount);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Main content
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header with Logo and School Name
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Row(
                        children: [
                          // Logo
                          pw.Container(
                            width: 80,
                            height: 80,
                            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                          ),
                          pw.SizedBox(width: 20),
                          // School Name and Title
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Bright Model School Larkana',
                                  style: pw.TextStyle(
                                    font: pw.Font.helveticaBold(),
                                    fontSize: 24,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  'Monthly Revenue Report',
                                  style: pw.TextStyle(
                                    font: pw.Font.helveticaBold(),
                                    fontSize: 20,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Text(
                                  'Month: $selectedMonth',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.Text(
                                  'Generated on: ${DateTime.now().toString().split('.')[0]}',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    color: PdfColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Summary
                    pw.Container(
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total Revenue for $selectedMonth:',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'PKR ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Daily Revenue Table
                    pw.Text(
                      'Daily Revenue Breakdown',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      children: [
                        // Header
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                          ),
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Date',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Revenue (PKR)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Data rows - show only days where revenue was collected
                        ...revenueRows,
                      ],
                    ),
                  ],
                ),

                // Footer positioned at bottom of page
                pw.Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Powered by: Tryunity Solutions',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Ph: +92-302-3476605 | Email: infotryunity@gmail.com | Website: Tryunitysolutions.com',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Open PDF directly in viewer
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Monthly_Revenue_Report_$selectedMonth.pdf',
      );
    } catch (e) {
      print('Error generating revenue report: $e');
      Get.snackbar(
        'Error',
        'Failed to generate revenue report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Widget _buildMonthlyRevenueOverview() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Month Picker
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Revenue Overview",
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "View day-wise revenue for a selected month",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                // Month Picker and Download Button Row
                Row(
                  children: [
                    // SaaS-style Month Picker
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Obx(
                            () => DropdownButton<String>(
                              value:
                                  controller.availableMonths.contains(
                                    controller.selectedMonth.value,
                                  )
                                  ? controller.selectedMonth.value
                                  : null,
                              items: controller.availableMonths.map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedMonth.value = newValue;
                                  controller.loadDailyRevenue();
                                }
                              },
                              hint: Text(
                                'Select month',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                              ),
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.primary,
                              ),
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Download Report Button
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, (1 - opacity) * 10),
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadRevenueReport(context),
                              icon: Icon(Icons.download, size: 18.sp),
                              label: Text(
                                'Download Report',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                shadowColor: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Date",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Revenue",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daily Revenue Table
          Container(
            height: 400.h,
            child: Obx(() {
              final revenueMap = controller.dailyRevenue;
              final selectedMonth = controller.selectedMonth.value;
              return ListView.builder(
                itemCount: 31, // Days 1-31
                itemBuilder: (context, index) {
                  int day = index + 1;
                  double revenue = revenueMap[day] ?? 0.0;
                  String revenueStr = revenue > 0
                      ? "PKR ${revenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}"
                      : "PKR 0";
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, (1 - opacity) * 20),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? Colors.grey.shade50
                                  : Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade100,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.blueAccent,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        "${day.toString().padLeft(2, '0')} $selectedMonth",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    revenueStr,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),

          // Summary Footer
          Obx(() {
            double total = controller.dailyRevenue.values.fold(
              0.0,
              (sum, amount) => sum + amount,
            );
            String totalStr =
                "PKR ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
            return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.green.shade700,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Total Revenue (${controller.selectedMonth.value}): ",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    totalStr,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
