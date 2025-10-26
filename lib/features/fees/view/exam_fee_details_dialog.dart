import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/exam_fee_model.dart';
import '../../../data/models/exam_paid_fee_model.dart';

class ExamFeeDetailsDialog extends StatefulWidget {
  final dynamic fee; // Can be ExamFeeModel or ExamPaidFeeModel

  const ExamFeeDetailsDialog({super.key, required this.fee});

  @override
  State<ExamFeeDetailsDialog> createState() => _ExamFeeDetailsDialogState();
}

class _ExamFeeDetailsDialogState extends State<ExamFeeDetailsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _progressPercentage {
    if (widget.fee is ExamFeeModel) {
      final fee = widget.fee as ExamFeeModel;
      return fee.totalFee > 0
          ? (fee.paidAmount / fee.totalFee).clamp(0.0, 1.0)
          : 0.0;
    } else if (widget.fee is ExamPaidFeeModel) {
      final fee = widget.fee as ExamPaidFeeModel;
      final totalFee = fee.totalFee ?? fee.paidAmount;
      return totalFee > 0
          ? (fee.paidAmount / totalFee).clamp(0.0, 1.0)
          : 1.0; // Default to 100% if no total fee available
    }
    return 0.0;
  }

  String get _progressMessage {
    final percentage = (_progressPercentage * 100).round();
    if (percentage == 100) {
      return '🎉 Congratulations! All exam fees have been paid!';
    } else if (percentage >= 75) {
      return '🚀 Excellent progress! You\'re almost done with exam fees.';
    } else if (percentage >= 50) {
      return '💪 Great job! You\'re halfway through your exam fees.';
    } else if (percentage >= 25) {
      return '📈 Good start! Keep up the momentum with exam fees.';
    } else {
      return '🎯 Let\'s get started! Begin paying your exam fees today.';
    }
  }

  String get _dialogTitle {
    if (widget.fee is ExamFeeModel) {
      final fee = widget.fee as ExamFeeModel;
      return fee.isPaid ? 'Paid Exam Fee Details' : 'Pending Exam Fee Details';
    }
    return 'Paid Exam Fee Details';
  }

  String get _rollNo {
    if (widget.fee is ExamFeeModel) {
      return (widget.fee as ExamFeeModel).rollNo ?? 'N/A';
    } else if (widget.fee is ExamPaidFeeModel) {
      return (widget.fee as ExamPaidFeeModel).rollNo ?? 'N/A';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _closeDialog(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping dialog
                    child: Container(
                      width: MediaQuery.of(context).size.width > 600
                          ? 500.w
                          : 350.w,
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProgressSection(),
                                  SizedBox(height: 20.h),
                                  _buildStudentDetailsCard(),
                                  SizedBox(height: 20.h),
                                  _buildFeeBreakdownCard(),
                                  SizedBox(height: 20.h),
                                  _buildActionButtons(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.school, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dialogTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Roll No: $_rollNo',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _closeDialog,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(Icons.close, color: Colors.grey[600], size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Text(
              'Payment Progress',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140.w,
                    height: 140.w,
                    child: CircularProgressIndicator(
                      value: _progressPercentage,
                      strokeWidth: 12.w,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressPercentage == 1.0
                            ? Colors.green
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${(_progressPercentage * 100).round()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _progressMessage,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetailsCard() {
    String studentName = '';
    String classInfo = '';
    String examInfo = '';

    if (widget.fee is ExamFeeModel) {
      final fee = widget.fee as ExamFeeModel;
      studentName = fee.studentName ?? 'Unknown';
      classInfo = '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim();
      examInfo = '${fee.examName ?? 'N/A'} - ${fee.examMonth ?? 'N/A'}';
    } else if (widget.fee is ExamPaidFeeModel) {
      final fee = widget.fee as ExamPaidFeeModel;
      studentName = fee.studentName ?? 'Unknown';
      classInfo = '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim();
      examInfo = fee.examName ?? 'N/A';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Student Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Student Name:', studentName),
            _buildInfoRow('Roll No:', _rollNo),
            _buildInfoRow('Class:', classInfo),
            _buildInfoRow('Exam:', examInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdownCard() {
    double totalFees = 0;
    double paidAmount = 0;
    double remainingAmount = 0;

    if (widget.fee is ExamFeeModel) {
      final fee = widget.fee as ExamFeeModel;
      totalFees = fee.totalFee;
      paidAmount = fee.paidAmount;
      remainingAmount = fee.remainingAmount;
    } else if (widget.fee is ExamPaidFeeModel) {
      final fee = widget.fee as ExamPaidFeeModel;
      totalFees =
          fee.totalFee ??
          fee.paidAmount; // Use totalFee if available, otherwise paidAmount
      paidAmount = fee.paidAmount;
      remainingAmount = (fee.totalFee ?? fee.paidAmount) - fee.paidAmount;
      // Ensure remaining amount never goes negative
      remainingAmount = remainingAmount < 0 ? 0.0 : remainingAmount;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Fee Breakdown',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildFeeRow(
              'Total Fees:',
              'Rs. ${totalFees.toStringAsFixed(0)}',
              Colors.black87,
            ),
            _buildFeeRow(
              'Paid Amount:',
              'Rs. ${paidAmount.toStringAsFixed(0)}',
              Colors.green[700]!,
            ),
            Divider(height: 16.h),
            _buildFeeRow(
              'Remaining Amount:',
              'Rs. ${remainingAmount.toStringAsFixed(0)}',
              remainingAmount == 0 ? Colors.green[700]! : Colors.red[700]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _closeDialog,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'Close',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  void _closeDialog() {
    _animationController.reverse().then((_) {
      Get.back();
    });
  }
}
