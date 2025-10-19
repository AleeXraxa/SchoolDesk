import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/students_controller.dart';

class StudentsSearchBar extends GetView<StudentsController> {
  const StudentsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
              child: TextField(
                onChanged: controller.updateSearchQuery,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Search students by name, father name, class, or contact...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.black38,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty ||
                        controller.filters.isNotEmpty) {
                      return IconButton(
                        onPressed: controller.clearFilters,
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 20.sp,
                        ),
                        tooltip: 'Clear filters',
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
