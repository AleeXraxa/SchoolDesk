import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StudentListItem extends StatefulWidget {
  final String rollNo;
  final String name;
  final String fatherName;
  final String studentClass;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentListItem({
    super.key,
    required this.rollNo,
    required this.name,
    required this.fatherName,
    required this.studentClass,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<StudentListItem> createState() => _StudentListItemState();
}

class _StudentListItemState extends State<StudentListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.primary.withOpacity(0.02)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Roll Number
              Container(
                width: 60.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    widget.rollNo,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.w),

              // Student Name
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Father: ${widget.fatherName}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Class
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.studentClass,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ),
              SizedBox(width: 20.w),

              // Actions
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.visibility,
                    color: Colors.blue,
                    onTap: widget.onView,
                    tooltip: 'View Details',
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    icon: Icons.edit,
                    color: Colors.orange,
                    onTap: widget.onEdit,
                    tooltip: 'Edit Student',
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    icon: Icons.delete,
                    color: Colors.red,
                    onTap: widget.onDelete,
                    tooltip: 'Delete Student',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
        ),
      ),
    );
  }
}
