import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: _hasError ? Colors.red : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Focus(
          onFocusChange: (focused) {
            setState(() => _isFocused = focused);
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (_hasError) {
                _validateField();
              }
            },
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                _hasError = error != null;
                _errorText = error;
              });
              return error;
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black38,
              ),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: _hasError
                          ? Colors.red
                          : _isFocused
                          ? AppColors.primary
                          : Colors.grey,
                      size: 20.sp,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: _hasError ? Colors.red : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: _hasError ? Colors.red : AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: _isFocused
                  ? AppColors.primary.withOpacity(0.02)
                  : Colors.grey.withOpacity(0.02),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              errorStyle: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
          ),
        ),
        if (_hasError && _errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            _errorText!,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.red,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  void _validateField() {
    final error = widget.validator?.call(widget.controller?.text);
    setState(() {
      _hasError = error != null;
      _errorText = error;
    });
  }
}
