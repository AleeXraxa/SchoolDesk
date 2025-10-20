import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/monthly_fee_model.dart';
import '../../../data/models/monthly_paid_fees_model.dart';
import '../../../data/models/monthly_payment_history_model.dart';
import '../service/monthly_fees_service.dart';

class MonthlyFeeDetailsDialog extends StatefulWidget {
  final dynamic fee; // Can be MonthlyFeeModel or MonthlyPaidFeesModel

  const MonthlyFeeDetailsDialog({super.key, required this.fee});

  @override
  State<MonthlyFeeDetailsDialog> createState() =>
      _MonthlyFeeDetailsDialogState();
}

class _MonthlyFeeDetailsDialogState extends State<MonthlyFeeDetailsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  List<MonthlyPaymentHistoryModel> _paymentHistory = [];
  bool _isLoadingHistory = false;

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
    _loadPaymentHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentHistory() async {
    if (widget.fee is MonthlyPaidFeesModel) {
      setState(() => _isLoadingHistory = true);
      try {
        _paymentHistory = widget.fee.individualPayments;
      } catch (e) {
        print('Error loading payment history: $e');
      } finally {
        setState(() => _isLoadingHistory = false);
      }
    } else if (widget.fee is MonthlyFeeModel) {
      setState(() => _isLoadingHistory = true);
      try {
        _paymentHistory =
            await MonthlyFeesService.getPaymentHistoryByMonthlyFeeId(
              widget.fee.id!,
            );
      } catch (e) {
        print('Error loading payment history: $e');
      } finally {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  double get _progressPercentage {
    if (widget.fee is MonthlyFeeModel) {
      final fee = widget.fee as MonthlyFeeModel;
      return fee.amount > 0
          ? (fee.paidAmount / fee.amount).clamp(0.0, 1.0)
          : 0.0;
    } else if (widget.fee is MonthlyPaidFeesModel) {
      final fee = widget.fee as MonthlyPaidFeesModel;
      return fee.totalFeeAmount > 0
          ? (fee.totalPaidAmount / fee.totalFeeAmount).clamp(0.0, 1.0)
          : 0.0;
    }
    return 0.0;
  }

  String get _progressMessage {
    final percentage = (_progressPercentage * 100).round();
    if (percentage == 100) {
      return '🎉 Congratulations! All monthly fees have been paid!';
    } else if (percentage >= 75) {
      return '🚀 Excellent progress! You\'re almost done with monthly fees.';
    } else if (percentage >= 50) {
      return '💪 Great job! You\'re halfway through your monthly fees.';
    } else if (percentage >= 25) {
      return '📈 Good start! Keep up the momentum with your monthly fees.';
    } else {
      return '🎯 Let\'s get started! Begin paying your monthly fees today.';
    }
  }

  String get _dialogTitle {
    if (widget.fee is MonthlyFeeModel) {
      final fee = widget.fee as MonthlyFeeModel;
      return fee.isPaid
          ? 'Paid Monthly Fee Details'
          : 'Pending Monthly Fee Details';
    }
    return 'Paid Monthly Fee Details';
  }

  String get _rollNo {
    if (widget.fee is MonthlyFeeModel) {
      return (widget.fee as MonthlyFeeModel).rollNo ?? 'N/A';
    } else if (widget.fee is MonthlyPaidFeesModel) {
      return (widget.fee as MonthlyPaidFeesModel).rollNo ?? 'N/A';
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
                                  if (_paymentHistory.isNotEmpty) ...[
                                    SizedBox(height: 20.h),
                                    _buildPaymentHistoryCard(),
                                  ],
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
            child: Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 20.sp,
            ),
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
    String month = '';

    if (widget.fee is MonthlyFeeModel) {
      final fee = widget.fee as MonthlyFeeModel;
      studentName = fee.studentName ?? 'Unknown';
      classInfo = '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim();
      month = fee.month;
    } else if (widget.fee is MonthlyPaidFeesModel) {
      final fee = widget.fee as MonthlyPaidFeesModel;
      studentName = fee.studentName ?? 'Unknown';
      classInfo = '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim();
      month = fee.month;
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
            _buildInfoRow('Month:', month),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdownCard() {
    double totalFees = 0;
    double paidAmount = 0;
    double remainingAmount = 0;

    if (widget.fee is MonthlyFeeModel) {
      final fee = widget.fee as MonthlyFeeModel;
      totalFees = fee.amount;
      paidAmount = fee.paidAmount;
      remainingAmount = fee.remainingAmount;
    } else if (widget.fee is MonthlyPaidFeesModel) {
      final fee = widget.fee as MonthlyPaidFeesModel;
      totalFees = fee.totalFeeAmount;
      paidAmount = fee.totalPaidAmount;
      remainingAmount = fee.remainingAmount;
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
              'Total Monthly Fees:',
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

  Widget _buildPaymentHistoryCard() {
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
                Icon(Icons.history, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Payment History',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_isLoadingHistory)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_paymentHistory.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    'No payment records yet',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: _paymentHistory.map((payment) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rs. ${payment.paidAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                              Text(
                                '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            payment.paymentMode,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
