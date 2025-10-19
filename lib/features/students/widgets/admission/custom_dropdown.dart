import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final String? label;
  final RxString selectedValue;
  final List<String> options;
  final IconData? icon;
  final String? Function(String?)? validator;
  final String? placeholder;
  final Function(String?)? onChanged;

  const CustomDropdown({
    super.key,
    this.label,
    required this.selectedValue,
    required this.options,
    this.icon,
    this.validator,
    this.placeholder,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasError = validator?.call(selectedValue.value) != null;
      final errorText = validator?.call(selectedValue.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: hasError ? Colors.red : Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? Colors.red : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey.withOpacity(0.02),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedValue.value,
              decoration: InputDecoration(
                prefixIcon: icon != null
                    ? Icon(
                        icon,
                        color: hasError ? Colors.red : AppColors.primary,
                        size: 20.sp,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                errorStyle: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.red,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: hasError ? Colors.red : AppColors.primary,
                size: 24.sp,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedValue.value = newValue;
                  onChanged?.call(newValue);
                }
              },
              validator: validator,
              items: [
                if (placeholder != null &&
                    (selectedValue.value.isEmpty ||
                        !options.contains(selectedValue.value)))
                  DropdownMenuItem<String>(
                    value: '',
                    enabled: false,
                    child: Text(
                      placeholder!,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ...options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: AppColors.primary, size: 18.sp),
                          SizedBox(width: 12.w),
                        ],
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          if (hasError && errorText != null) ...[
            SizedBox(height: 4.h),
            Text(
              errorText,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      );
    });
  }
}
