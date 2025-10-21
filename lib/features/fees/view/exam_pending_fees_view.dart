import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/exam_fees_controller.dart';
import '../../../widgets/loading_dialog.dart';
import '../../../widgets/result_dialog.dart';
import '../../../core/theme/app_colors.dart';

class ExamPendingFeesView extends StatelessWidget {
  const ExamPendingFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available with error handling
    try {
      if (!Get.isRegistered<ExamFeesController>()) {
        Get.put(ExamFeesController(), permanent: true);
      }
      final controller = Get.find<ExamFeesController>();

      return Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final fees = controller.getDisplayedPendingFees();

        if (fees.isEmpty) {
          return Column(
            children: [
              // Header - Always show header to maintain consistent layout
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange[700], size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Pending Exam Fees (0)',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
              // Empty state content
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pending_actions_outlined,
                        size: 48.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No records found',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.pending, color: Colors.orange[700], size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Pending Exam Fees (${fees.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
            // Table Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Roll No',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Student Name',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Exam Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Total Fee',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Paid',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Remaining',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Table Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(fees.length, (index) {
                    final fee = fees[index];
                    final isEvenRow = index % 2 == 0;

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isEvenRow ? Colors.white : Colors.grey[25],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: _buildExamFeeCells(fee, controller, context),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      });
    } catch (e, stackTrace) {
      // Log the error for debugging
      print('Error in ExamPendingFeesView build: $e');
      print('Stack trace: $stackTrace');

      // Fallback UI for when controller is not available
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
            SizedBox(height: 16.h),
            Text(
              'Unable to load exam fees',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please try again later',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
  }

  List<Widget> _buildExamFeeCells(
    dynamic fee,
    ExamFeesController controller,
    BuildContext context,
  ) {
    return [
      Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            fee.rollNo ?? 'N/A',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            fee.studentName ?? 'Unknown Student',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fee.examName ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim(),
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            'PKR ${fee.totalFee?.toStringAsFixed(0) ?? '0'}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            'PKR ${fee.paidAmount?.toStringAsFixed(0) ?? '0'}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            'PKR ${fee.remainingAmount?.toStringAsFixed(0) ?? '0'}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: fee.remainingAmount > 0
                  ? Colors.orange[700]
                  : Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showPaymentDialog(context, fee, controller),
                icon: Icon(Icons.payment, size: 18.sp),
                tooltip: 'Pay Fee',
                color: Colors.green[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () => _showExamFeeDetailsDialog(fee),
                icon: Icon(Icons.visibility, size: 18.sp),
                tooltip: 'View Details',
                color: Colors.blue[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showExamFeeDetailsDialog(dynamic fee) {
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
                width: 450.w,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Exam Fee Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Fee Details
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Student Name',
                            fee.studentName ?? 'Unknown',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow('Roll No', fee.rollNo ?? 'N/A'),
                          SizedBox(height: 12.h),
                          _buildDetailRow('Exam Name', fee.examName ?? 'N/A'),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            'Class',
                            '${fee.className ?? 'N/A'} ${fee.section ?? ''}'
                                .trim(),
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            'Total Amount',
                            'PKR ${fee.totalFee?.toStringAsFixed(0) ?? '0'}',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            'Amount Paid',
                            'PKR ${fee.paidAmount?.toStringAsFixed(0) ?? '0'}',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            'Remaining Amount',
                            'PKR ${fee.remainingAmount?.toStringAsFixed(0) ?? '0'}',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow('Status', fee.status ?? 'Pending'),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Close',
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
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    dynamic fee,
    ExamFeesController controller,
  ) {
    final paymentController = TextEditingController();
    final remarksController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedPaymentMode = 'Cash'; // Default payment mode

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
                                'Pay Exam Fees',
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

                        // Summary Section
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Fees',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'PKR ${fee.totalFee?.toStringAsFixed(0) ?? '0'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Paid',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'PKR ${fee.paidAmount?.toStringAsFixed(0) ?? '0'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Remaining Fees',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'PKR ${fee.remainingAmount?.toStringAsFixed(0) ?? '0'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: fee.remainingAmount > 0
                                          ? Colors.orange[700]
                                          : Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              // Progress Indicator
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Payment Progress',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${((fee.paidAmount / fee.totalFee) * 100).toStringAsFixed(1)}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: fee.paidAmount == fee.totalFee
                                              ? Colors.green[700]
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4.r),
                                      child: LinearProgressIndicator(
                                        value: fee.totalFee > 0
                                            ? fee.paidAmount / fee.totalFee
                                            : 0.0,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              fee.paidAmount == fee.totalFee
                                                  ? Colors.green[600]!
                                                  : AppColors.primary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Student Details Card
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Information',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _buildInfoRow('Roll No', fee.rollNo ?? 'N/A'),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Student Name',
                                fee.studentName ?? 'Unknown',
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow('Exam', fee.examName ?? 'N/A'),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Class',
                                '${fee.className ?? 'N/A'} ${fee.section ?? ''}'
                                    .trim(),
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Total Fees',
                                'PKR ${fee.totalFee?.toStringAsFixed(0) ?? '0'}',
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Paid Fees',
                                'PKR ${fee.paidAmount?.toStringAsFixed(0) ?? '0'}',
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Remaining Fees',
                                'PKR ${fee.remainingAmount?.toStringAsFixed(0) ?? '0'}',
                              ),
                            ],
                          ),
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
                                  return 'Amount cannot exceed remaining balance of PKR ${fee.remainingAmount.toStringAsFixed(0)}';
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
                                    final success = await controller
                                        .processPayment(
                                          fee.id,
                                          paymentAmount,
                                          selectedPaymentMode,
                                        );

                                    if (success) {
                                      Get.back(); // Close payment dialog

                                      // Show success dialog
                                      _showPaymentSuccessDialog(
                                        context,
                                        fee,
                                        paymentAmount,
                                        selectedPaymentMode,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showPaymentSuccessDialog(
    BuildContext context,
    dynamic fee,
    double paymentAmount,
    String paymentMode,
  ) {
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
                width: MediaQuery.of(context).size.width > 600 ? 400.w : 350.w,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green[400]!,
                                  Colors.green[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Title with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, (1 - opacity) * 20),
                            child: Text(
                              'Payment Successful!',
                              style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Payment Details Card with Modern Design
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 30),
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.grey[50]!, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Student Info with Icons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildSuccessInfoRow(
                                          'Student Name',
                                          fee.studentName ?? 'Unknown',
                                          Icons.person,
                                          Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: _buildSuccessInfoRow(
                                          'Roll No',
                                          fee.rollNo ?? 'N/A',
                                          Icons.badge,
                                          Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Divider(color: Colors.grey[300]),
                                  SizedBox(height: 16.h),

                                  // Payment Details
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildSuccessInfoRow(
                                          'Paid Amount',
                                          'PKR ${paymentAmount.toStringAsFixed(0)}',
                                          Icons.attach_money,
                                          Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: _buildSuccessInfoRow(
                                          'Payment Mode',
                                          paymentMode,
                                          _getPaymentModeIcon(paymentMode),
                                          Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Success Message with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            'The exam fee payment has been processed successfully.',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // OK Button with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 4,
                                shadowColor: Colors.green.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Continue',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildSuccessInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  IconData _getPaymentModeIcon(String mode) {
    switch (mode) {
      case 'Cash':
        return Icons.money;
      case 'Card':
        return Icons.credit_card;
      case 'Bank Transfer':
        return Icons.account_balance;
      case 'Online':
        return Icons.web;
      case 'Cheque':
        return Icons.receipt;
      default:
        return Icons.payment;
    }
  }
}
