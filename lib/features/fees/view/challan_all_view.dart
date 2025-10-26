import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ChallanAllView extends StatelessWidget {
  const ChallanAllView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available with error handling
    try {
      // ChallanController removed - show dummy data instead
      final controller = null;

      return Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final challans = controller.getDisplayedChallans();

        if (challans.isEmpty) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - opacity)),
                  child: Column(
                    children: [
                      // Header - Always show header to maintain consistent layout
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[50]!, Colors.indigo[50]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r),
                          ),
                          border: Border.all(
                            color: Colors.blue[100]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: Colors.blue[700],
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'All Challans (0)',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[800],
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Empty state content
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(40.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80.w,
                                height: 80.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey[100]!,
                                      Colors.grey[200]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  size: 36.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'No challans generated yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Pay any fee to generate your first challan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, 15 * (1 - opacity)),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.indigo[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                        border: Border.all(color: Colors.blue[100]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: Colors.blue[700],
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'All Challans (${challans.length})',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue[800],
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.08),
                            AppColors.primary.withOpacity(0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Challan ID',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Student Name',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Class & Section',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Fee Type',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Total Amount',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Generated On',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Actions',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Body
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(challans.length, (index) {
                            final challan = challans[index];
                            final isEvenRow = index % 2 == 0;

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 400 + (index * 50),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, rowOpacity, child) {
                                return Opacity(
                                  opacity: rowOpacity,
                                  child: Transform.translate(
                                    offset: Offset(0, 10 * (1 - rowOpacity)),
                                    child: MouseRegion(
                                      onEnter: (_) {
                                        // Hover effect could be added here with state management
                                      },
                                      onExit: (_) {
                                        // Hover effect could be added here with state management
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeInOut,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                          vertical: 14.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isEvenRow
                                              ? Colors.white
                                              : Colors.grey[25],
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[100]!,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: _buildChallanCells(
                                            challan,
                                            controller,
                                            context,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    } catch (e, stackTrace) {
      // Log the error for debugging
      print('Error in ChallanAllView build: $e');
      print('Stack trace: $stackTrace');

      // Fallback UI for when controller is not available
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
            SizedBox(height: 16.h),
            Text(
              'Unable to load challans',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please try again later',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
  }

  List<Widget> _buildChallanCells(
    dynamic challan,
    dynamic controller,
    BuildContext context,
  ) {
    return [
      Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            challan.challanId ?? 'N/A',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            challan.studentName ?? 'Unknown Student',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            '${challan.className ?? 'N/A'} ${challan.section ?? ''}'.trim(),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            challan.feeType ?? 'Admission',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            'PKR ${challan.amountPaid?.toStringAsFixed(0) ?? '0'}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: challan.status == 'Paid'
                  ? Colors.green[100]
                  : challan.status == 'Partially Paid'
                  ? Colors.orange[100]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              challan.status ?? 'Generated',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: challan.status == 'Paid'
                    ? Colors.green[700]
                    : challan.status == 'Partially Paid'
                    ? Colors.orange[700]
                    : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            challan.generatedAt != null
                ? '${challan.generatedAt.day}/${challan.generatedAt.month}/${challan.generatedAt.year}'
                : 'N/A',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showChallanDetailsDialog(challan),
                icon: Icon(Icons.visibility, size: 18.sp),
                tooltip: 'View Details',
                color: Colors.blue[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () => _downloadChallan(challan),
                icon: Icon(Icons.download, size: 18.sp),
                tooltip: 'Download PDF',
                color: Colors.green[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showChallanDetailsDialog(dynamic challan) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - opacity)),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: MediaQuery.of(context).size.width > 1200
                            ? 800.w
                            : MediaQuery.of(context).size.width > 800
                            ? 700.w
                            : MediaQuery.of(context).size.width > 600
                            ? 600.w
                            : 500.w,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey[200]!.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Modern Header with Gradient Background
                            Container(
                              padding: EdgeInsets.all(32.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.08),
                                    AppColors.primary.withOpacity(0.04),
                                    Colors.white,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(28.r),
                                  topRight: Radius.circular(28.r),
                                ),
                              ),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                builder: (context, headerOpacity, child) {
                                  return Opacity(
                                    opacity: headerOpacity,
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        15 * (1 - headerOpacity),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 56.w,
                                            height: 56.w,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.primary.withOpacity(
                                                    0.8,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.receipt_long,
                                              color: Colors.white,
                                              size: 28.sp,
                                            ),
                                          ),
                                          SizedBox(width: 24.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Challan Details',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 24.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.black87,
                                                    letterSpacing: -0.8,
                                                  ),
                                                ),
                                                SizedBox(height: 6.h),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 16.w,
                                                            vertical: 6.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            challan.status ==
                                                                'Paid'
                                                            ? Colors.green[50]
                                                            : challan.status ==
                                                                  'Partially Paid'
                                                            ? Colors.orange[50]
                                                            : Colors.blue[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.r,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              challan.status ==
                                                                  'Paid'
                                                              ? Colors
                                                                    .green[200]!
                                                              : challan.status ==
                                                                    'Partially Paid'
                                                              ? Colors
                                                                    .orange[200]!
                                                              : Colors
                                                                    .blue[200]!,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            challan.status ==
                                                                    'Paid'
                                                                ? Icons
                                                                      .check_circle
                                                                : challan.status ==
                                                                      'Partially Paid'
                                                                ? Icons.pending
                                                                : Icons
                                                                      .schedule,
                                                            size: 14.sp,
                                                            color:
                                                                challan.status ==
                                                                    'Paid'
                                                                ? Colors
                                                                      .green[700]
                                                                : challan.status ==
                                                                      'Partially Paid'
                                                                ? Colors
                                                                      .orange[700]
                                                                : Colors
                                                                      .blue[700],
                                                          ),
                                                          SizedBox(width: 6.w),
                                                          Text(
                                                            challan.status ??
                                                                'Generated',
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  challan.status ==
                                                                      'Paid'
                                                                  ? Colors
                                                                        .green[700]
                                                                  : challan.status ==
                                                                        'Partially Paid'
                                                                  ? Colors
                                                                        .orange[700]
                                                                  : Colors
                                                                        .blue[700],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 16.w,
                                                            vertical: 6.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.r,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              Colors.grey[200]!,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'ID: ${challan.challanId}',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .grey[700],
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Content Area
                            Flexible(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(32.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Two-column layout for Student Info and Fee Breakdown
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      builder: (context, contentOpacity, child) {
                                        return Opacity(
                                          opacity: contentOpacity,
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              20 * (1 - contentOpacity),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Left Column - Student Info
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                      20.w,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.grey[50]!,
                                                          Colors.white,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16.r,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Colors.grey[200]!,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.person,
                                                              color: Colors
                                                                  .blue[600],
                                                              size: 18.sp,
                                                            ),
                                                            SizedBox(
                                                              width: 8.w,
                                                            ),
                                                            Text(
                                                              'Student Information',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 16.h),
                                                        _buildEnhancedInfoRow(
                                                          'Name',
                                                          challan.studentName ??
                                                              'N/A',
                                                          Icons.badge,
                                                        ),
                                                        SizedBox(height: 12.h),
                                                        _buildEnhancedInfoRow(
                                                          'Roll No',
                                                          challan.rollNo ??
                                                              'N/A',
                                                          Icons
                                                              .confirmation_number,
                                                        ),
                                                        SizedBox(height: 12.h),
                                                        _buildEnhancedInfoRow(
                                                          'Class',
                                                          '${challan.className ?? 'N/A'} ${challan.section ?? ''}'
                                                              .trim(),
                                                          Icons.class_,
                                                        ),
                                                        SizedBox(height: 12.h),
                                                        _buildEnhancedInfoRow(
                                                          'Month',
                                                          challan.month ??
                                                              'N/A',
                                                          Icons.calendar_month,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 24.w),
                                                // Right Column - Fee Breakdown and Total
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    children: [
                                                      // Fee Breakdown
                                                      Container(
                                                        padding: EdgeInsets.all(
                                                          20.w,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                                colors: [
                                                                  Colors
                                                                      .grey[50]!,
                                                                  Colors.white,
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16.r,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey[200]!,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .attach_money,
                                                                  color: Colors
                                                                      .green[600],
                                                                  size: 18.sp,
                                                                ),
                                                                SizedBox(
                                                                  width: 8.w,
                                                                ),
                                                                Text(
                                                                  'Fee Breakdown',
                                                                  style: GoogleFonts.inter(
                                                                    fontSize:
                                                                        16.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 16.h,
                                                            ),
                                                            // Fee items not available in current challan structure
                                                            // Display single fee item based on challan data
                                                            Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    bottom: 8.h,
                                                                  ),
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    12.w,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12.r,
                                                                    ),
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .grey[200]!,
                                                                  width: 1,
                                                                ),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                          0.03,
                                                                        ),
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        const Offset(
                                                                          0,
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          challan.feeType ??
                                                                              'Admission Fee',
                                                                          style: GoogleFonts.inter(
                                                                            fontSize:
                                                                                13.sp,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Payment Date: ${challan.paymentDate != null ? '${challan.paymentDate.day}/${challan.paymentDate.month}/${challan.paymentDate.year}' : 'N/A'}',
                                                                          style: GoogleFonts.inter(
                                                                            fontSize:
                                                                                11.sp,
                                                                            color:
                                                                                Colors.grey[600],
                                                                            height:
                                                                                1.3,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 1,
                                                                    child: Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12.w,
                                                                        vertical:
                                                                            6.h,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: AppColors
                                                                            .primary
                                                                            .withOpacity(
                                                                              0.1,
                                                                            ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20.r,
                                                                            ),
                                                                      ),
                                                                      child: Text(
                                                                        'PKR ${challan.amountPaid?.toStringAsFixed(0) ?? '0'}',
                                                                        style: GoogleFonts.inter(
                                                                          fontSize:
                                                                              13.sp,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color:
                                                                              AppColors.primary,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 16.h),
                                                      // Total Amount Card
                                                      Container(
                                                        padding: EdgeInsets.all(
                                                          20.w,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              AppColors.primary
                                                                  .withOpacity(
                                                                    0.05,
                                                                  ),
                                                              AppColors.primary
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16.r,
                                                              ),
                                                          border: Border.all(
                                                            color: AppColors
                                                                .primary
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    'Total Amount',
                                                                    style: GoogleFonts.inter(
                                                                      fontSize:
                                                                          16.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 1,
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16.w,
                                                                      vertical:
                                                                          8.h,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                        colors: [
                                                                          AppColors
                                                                              .primary,
                                                                          AppColors.primary.withOpacity(
                                                                            0.8,
                                                                          ),
                                                                        ],
                                                                        begin: Alignment
                                                                            .topLeft,
                                                                        end: Alignment
                                                                            .bottomRight,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            20.r,
                                                                          ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: AppColors.primary.withOpacity(
                                                                            0.3,
                                                                          ),
                                                                          blurRadius:
                                                                              8,
                                                                          offset: const Offset(
                                                                            0,
                                                                            3,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Text(
                                                                      'PKR ${challan.amountPaid?.toStringAsFixed(0) ?? '0'}',
                                                                      style: GoogleFonts.inter(
                                                                        fontSize:
                                                                            16.sp,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: 32.h),

                                    // Enhanced Action Buttons
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 700,
                                      ),
                                      builder: (context, buttonOpacity, child) {
                                        return Opacity(
                                          opacity: buttonOpacity,
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              15 * (1 - buttonOpacity),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _downloadChallan(
                                                          challan,
                                                        ),
                                                    icon: Icon(
                                                      Icons.download,
                                                      size: 20.sp,
                                                    ),
                                                    label: Text(
                                                      'Download PDF',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                        color:
                                                            AppColors.primary,
                                                        width: 1.5,
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 16.h,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16.w),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => Get.back(),
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 20.sp,
                                                    ),
                                                    label: Text(
                                                      'Close',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 16.h,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                      ),
                                                      elevation: 4,
                                                      shadowColor: AppColors
                                                          .primary
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 14.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _downloadChallan(dynamic challan) {
    // TODO: Implement PDF download functionality
    Get.snackbar('Info', 'PDF download feature coming soon');
  }
}
