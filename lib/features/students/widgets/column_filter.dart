import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/students_controller.dart';

class ColumnFilter extends StatelessWidget {
  final String column;
  final String label;

  const ColumnFilter({super.key, required this.column, required this.label});

  @override
  Widget build(BuildContext context) {
    return GetX<StudentsController>(
      builder: (controller) {
        final uniqueValues = controller.getUniqueValues(column);
        final currentFilter = controller.filters[column] ?? '';

        return PopupMenuButton<String>(
          onSelected: (value) {
            controller.updateFilter(column, value);
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: '',
              child: Row(
                children: [
                  Icon(
                    currentFilter.isEmpty
                        ? Icons.check
                        : Icons.radio_button_unchecked,
                    color: currentFilter.isEmpty
                        ? AppColors.primary
                        : Colors.grey,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'All $label',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: currentFilter.isEmpty
                          ? AppColors.primary
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            ...uniqueValues.map(
              (value) => PopupMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(
                      currentFilter == value
                          ? Icons.check
                          : Icons.radio_button_unchecked,
                      color: currentFilter == value
                          ? AppColors.primary
                          : Colors.grey,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: currentFilter == value
                            ? AppColors.primary
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: currentFilter.isNotEmpty
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: currentFilter.isNotEmpty
                        ? AppColors.primary
                        : Colors.black87,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.filter_list,
                  color: currentFilter.isNotEmpty
                      ? AppColors.primary
                      : Colors.grey,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
