import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/misc_fee_model.dart';
import '../../../data/models/misc_paid_fee_model.dart';
import '../controller/misc_fees_controller.dart';
import '../service/misc_fees_service.dart';

class MiscFeeDetailsDialog extends StatefulWidget {
  final dynamic fee; // Can be MiscFeeModel or MiscPaidFeeModel

  const MiscFeeDetailsDialog({super.key, required this.fee});

  @override
  State<MiscFeeDetailsDialog> createState() => _MiscFeeDetailsDialogState();
}

class _MiscFeeDetailsDialogState extends State<MiscFeeDetailsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  List<MiscPaidFeeModel> _paymentHistory = [];
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

  double get _progressPercentage {
    if (widget.fee is MiscFeeModel) {
      final fee = widget.fee as MiscFeeModel;
      return fee.totalFee > 0
          ? (fee.paidAmount / fee.totalFee).clamp(0.0, 1.0)
          : 0.0;
    } else if (widget.fee is MiscPaidFeeModel) {
      final fee = widget.fee as MiscPaidFeeModel;
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
      return '🎉 Congratulations! All misc fees have been paid!';
    } else if (percentage >= 75) {
      return '🚀 Excellent progress! You\'re almost done with misc fees.';
    } else if (percentage >= 50) {
      return '💪 Great job! You\'re halfway through your misc fees.';
    } else if (percentage >= 25) {
      return '📈 Good start! Keep up the momentum with misc fees.';
    } else {
      return '🎯 Let\'s get started! Begin paying your misc fees today.';
    }
  }

  String get _dialogTitle {
    if (widget.fee is MiscFeeModel) {
      final fee = widget.fee as MiscFeeModel;
      return fee.isPaid ? 'Paid Misc Fee Details' : 'Pending Misc Fee Details';
    }
    return 'Paid Misc Fee Details';
  }

  String get _rollNo {
    if (widget.fee is MiscFeeModel) {
      return (widget.fee as MiscFeeModel).rollNo ?? 'N/A';
    } else if (widget.fee is MiscPaidFeeModel) {
      return (widget.fee as MiscPaidFeeModel).rollNo ?? 'N/A';
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
                                  if (widget.fee is MiscFeeModel) ...[
                                    SizedBox(height: 20.h),
                                    _buildPaymentActions(),
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
              Icons.attach_money,
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
    String feeTypeInfo = '';

    if (widget.fee is MiscFeeModel) {
      final fee = widget.fee as MiscFeeModel;
      studentName = fee.studentName ?? 'Unknown';
      classInfo = '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim();
      feeTypeInfo = '${fee.miscFeeType ?? 'N/A'} - ${fee.month ?? 'N/A'}';
    } else if (widget.fee is MiscPaidFeeModel) {
      final fee = widget.fee as MiscPaidFeeModel;
      studentName = fee.studentName ?? 'Unknown';
      classInfo = '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim();
      feeTypeInfo = fee.miscFeeType ?? 'N/A';
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
            _buildInfoRow('Fee Type:', feeTypeInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdownCard() {
    double totalFees = 0;
    double paidAmount = 0;
    double remainingAmount = 0;

    if (widget.fee is MiscFeeModel) {
      final fee = widget.fee as MiscFeeModel;
      totalFees = fee.totalFee;
      paidAmount = fee.paidAmount;
      remainingAmount = fee.remainingAmount;
    } else if (widget.fee is MiscPaidFeeModel) {
      final fee = widget.fee as MiscPaidFeeModel;
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  Widget _buildPaymentActions() {
    final fee = widget.fee as MiscFeeModel;
    if (fee.isPaid) return const SizedBox.shrink();

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
                Icon(Icons.payment, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Payment Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentDialog(context, fee),
                icon: Icon(Icons.payment, size: 18.sp),
                label: Text(
                  'Record Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _closeDialog,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              side: BorderSide(color: Colors.grey[300]!),
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
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context, MiscFeeModel fee) {
    final paymentController = TextEditingController();
    final remarksController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedPaymentMode = 'Cash';

    final paymentModes = [
      'Cash',
      'Card',
      'Bank Transfer',
      'Online',
      'Cheque',
      'Other',
    ];

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 500.w : 450.w,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.payment,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Text(
                                'Record Misc Fee Payment',
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Payment Form
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Details',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Payment Amount
                            TextFormField(
                              controller: paymentController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Current Payment Amount (PKR)',
                                hintText: 'Enter payment amount',
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Payment amount is required';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Please enter a valid positive amount';
                                }
                                if (amount > fee.remainingAmount) {
                                  return 'Amount cannot exceed remaining balance of Rs. ${fee.remainingAmount.toStringAsFixed(0)}';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            // Mode of Payment
                            DropdownButtonFormField<String>(
                              value: selectedPaymentMode,
                              decoration: InputDecoration(
                                labelText: 'Mode of Payment',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: paymentModes.map((mode) {
                                return DropdownMenuItem(
                                  value: mode,
                                  child: Text(
                                    mode,
                                    style: GoogleFonts.poppins(fontSize: 14.sp),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedPaymentMode = value ?? 'Cash';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a payment mode';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            // Remarks
                            TextFormField(
                              controller: remarksController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Remarks (Optional)',
                                hintText: 'Add any additional notes or remarks',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.poppins(fontSize: 14.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    final paymentAmount = double.parse(
                                      paymentController.text,
                                    );

                                    // Additional validation: check if payment exceeds remaining amount
                                    if (paymentAmount > fee.remainingAmount) {
                                      Get.snackbar(
                                        'Invalid Payment',
                                        'Payment amount cannot exceed remaining balance of PKR ${fee.remainingAmount.toStringAsFixed(0)}',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 3),
                                      );
                                      return;
                                    }

                                    // Process payment
                                    final controller =
                                        Get.find<MiscFeesController>();
                                    final success = await controller
                                        .processPayment(
                                          fee.id!,
                                          paymentAmount,
                                          selectedPaymentMode,
                                        );

                                    if (success) {
                                      Get.back(); // Close payment dialog
                                      Get.back(); // Close details dialog
                                      Get.snackbar(
                                        'Success',
                                        'Misc fee payment processed successfully',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  'Pay Now',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      barrierDismissible: true,
    );
  }

  Future<void> _loadPaymentHistory() async {
    if (widget.fee is MiscPaidFeeModel) {
      setState(() => _isLoadingHistory = true);
      try {
        // For paid misc fees, get all individual payment entries for this student and fee type
        final fee = widget.fee as MiscPaidFeeModel;
        final paidEntries = await MiscFeesService.getMiscPaidEntriesByStudent(
          fee.studentId!,
          fee.miscFeeType!,
        );

        print('Misc Fee Details → Total Paid Entries: ${paidEntries.length}');

        _paymentHistory = paidEntries;
      } catch (e) {
        print('Error loading payment history: $e');
      } finally {
        setState(() => _isLoadingHistory = false);
      }
    } else if (widget.fee is MiscFeeModel) {
      setState(() => _isLoadingHistory = true);
      try {
        // For pending fees, get payment history by misc fee ID
        // This would require a service method similar to monthly fees
        // For now, we'll keep it empty as the current implementation doesn't support partial payments for pending misc fees
        _paymentHistory = [];
      } catch (e) {
        print('Error loading payment history: $e');
      } finally {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  void _closeDialog() {
    _animationController.reverse().then((_) {
      Get.back();
    });
  }
}
