import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../features/students/service/student_service.dart';

class BirthdayNotificationsDialog extends StatefulWidget {
  const BirthdayNotificationsDialog({super.key});

  @override
  State<BirthdayNotificationsDialog> createState() =>
      _BirthdayNotificationsDialogState();
}

class _BirthdayNotificationsDialogState
    extends State<BirthdayNotificationsDialog>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> upcomingBirthdays = [];
  bool isLoading = true;

  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogScaleAnimation;
  late Animation<double> _dialogOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _loadUpcomingBirthdays();

    // Dialog entrance animation
    _dialogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _dialogScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _dialogOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _dialogAnimationController.forward();
  }

  @override
  void dispose() {
    _dialogAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUpcomingBirthdays() async {
    try {
      final birthdays = await StudentService.getUpcomingBirthdays(
        daysAhead: 15,
      );
      setState(() {
        upcomingBirthdays = birthdays;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading upcoming birthdays: $e');
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load birthday notifications',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _dialogScaleAnimation.value,
          child: Opacity(
            opacity: _dialogOpacityAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 600.w,
                constraints: BoxConstraints(maxHeight: 600.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.accent.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: const Icon(
                              Icons.cake,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upcoming Birthdays',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Students celebrating birthdays in the next 15 days',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 400.h),
                        child: isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40.w,
                                      height: 40.w,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.accent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Loading birthdays...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : upcomingBirthdays.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cake_outlined,
                                      size: 64.sp,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'No upcoming birthdays',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'in the next 15 days',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(16.w),
                                itemCount: upcomingBirthdays.length,
                                itemBuilder: (context, index) {
                                  final birthday = upcomingBirthdays[index];
                                  final daysUntil =
                                      birthday['daysUntil'] as int;

                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                      milliseconds: 400 + (index * 100),
                                    ),
                                    builder: (context, opacity, child) {
                                      return Opacity(
                                        opacity: opacity,
                                        child: Transform.translate(
                                          offset: Offset(0, (1 - opacity) * 20),
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              bottom: 12.h,
                                            ),
                                            padding: EdgeInsets.all(16.w),
                                            decoration: BoxDecoration(
                                              color: daysUntil == 0
                                                  ? Colors.yellow[50]
                                                  : Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: daysUntil == 0
                                                    ? Colors.yellow[200]!
                                                    : Colors.blue[200]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40.w,
                                                  height: 40.w,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: daysUntil == 0
                                                          ? [
                                                              Colors
                                                                  .yellow[600]!,
                                                              Colors
                                                                  .orange[600]!,
                                                            ]
                                                          : [
                                                              Colors.blue[600]!,
                                                              Colors
                                                                  .purple[600]!,
                                                            ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    daysUntil == 0
                                                        ? Icons.celebration
                                                        : Icons.cake,
                                                    color: Colors.white,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                                SizedBox(width: 16.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        birthday['name']
                                                            as String,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                      ),
                                                      SizedBox(height: 4.h),
                                                      Text(
                                                        'DOB: ${_formatDate(birthday['dob'] as DateTime)}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 12.sp,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                      ),
                                                      Text(
                                                        'Class: ${birthday['class']}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 12.sp,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: daysUntil == 0
                                                        ? Colors.yellow[100]
                                                        : Colors.blue[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    daysUntil == 0
                                                        ? 'Today!'
                                                        : 'In $daysUntil days',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: daysUntil == 0
                                                          ? Colors.orange[800]
                                                          : Colors.blue[800],
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
                              ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[100]!, width: 1),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Close',
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
