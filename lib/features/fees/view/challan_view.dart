import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/challan_controller.dart';
import 'challan_main_view.dart';

class ChallanView extends GetView<ChallanController> {
  const ChallanView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChallanController());

    return const ChallanMainView();
  }

  Widget _buildDummyAllChallansView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Challan Management',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Feature coming soon',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyGenerateView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Generate Challans',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Feature coming soon',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: Container(
              padding: EdgeInsets.all(24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Challan Management',
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Generate and manage student fee challans',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: ElevatedButton.icon(
                                onPressed: () => _showFilterDialog(),
                                icon: Icon(Icons.filter_list, size: 18.sp),
                                label: Text(
                                  'Filter',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF3A7BD5),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 14.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    side: const BorderSide(
                                      color: Color(0xFF3A7BD5),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 16.w),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: ElevatedButton.icon(
                                onPressed: () => _showGenerateChallanDialog(),
                                icon: Icon(Icons.add, size: 18.sp),
                                label: Text(
                                  'Generate Challan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A7BD5),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: const Color(
                                    0xFF3A7BD5,
                                  ).withOpacity(0.3),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 14.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
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
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - opacity)),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[100]!, width: 1),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3A7BD5), const Color(0xFF00D2FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3A7BD5).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                labelPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt, size: 18.sp),
                        SizedBox(width: 8.w),
                        const Text('All Challans'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 18.sp),
                        SizedBox(width: 8.w),
                        const Text('Generate Challan'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 18.sp),
                        SizedBox(width: 8.w),
                        const Text('Search & Filter'),
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

  Widget _buildSearchFilterView() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - opacity)),
            child: Container(
              margin: EdgeInsets.all(24.w),
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.grey[100]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[50]!, Colors.indigo[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.blue[100]!, width: 2),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 40.sp,
                      color: Colors.blue[600],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Advanced Search & Filtering',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Use the filter button in the header to apply advanced filters, or use the search functionality in the "All Challans" tab.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.blue[100]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[600],
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Tip: Combine multiple filters for precise results',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

  void _showFilterDialog() {
    Get.snackbar('Info', 'Filter functionality coming soon');
  }

  void _showGenerateChallanDialog() {
    Get.snackbar('Info', 'Challan generation coming soon');
  }
}
