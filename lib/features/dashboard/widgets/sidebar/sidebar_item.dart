import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'sidebar_controller.dart';

class SidebarItem extends StatefulWidget {
  final String icon;
  final String title;
  final int index;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.index,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GetX<SidebarController>(
      builder: (controller) {
        final isActive = controller.isItemActive(widget.index);
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.15)
                  : _isHovered
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.selectItem(widget.index),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 4.w,
                        height: isActive ? 24.h : 0,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: isActive ? 12.w : 16.w),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : _isHovered
                              ? AppColors.primary.withOpacity(0.7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          _getIconData(widget.icon),
                          color: isActive || _isHovered
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          size: 12.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : _isHovered
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: isActive || _isHovered
                                ? Colors.white
                                : Colors.white.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'students':
        return Icons.people;
      case 'classes':
        return Icons.class_;
      case 'fees':
        return Icons.attach_money;
      case 'challans':
        return Icons.receipt;
      case 'attendance':
        return Icons.check_circle;
      case 'expenses':
        return Icons.account_balance_wallet;
      case 'users':
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}
