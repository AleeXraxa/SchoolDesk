import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/fees_controller.dart';
import '../controller/admission_fees_controller.dart';
import '../../../data/models/admission_fee_model.dart';
import 'admission_fee_details_dialog.dart';

// Add error handling import
import 'dart:async';

class PendingFeesView extends StatelessWidget {
  const PendingFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available with error handling
    try {
      if (!Get.isRegistered<AdmissionFeesController>()) {
        Get.put(AdmissionFeesController(), permanent: true);
      }
      final admissionController = Get.find<AdmissionFeesController>();

      return Obx(() {
        if (admissionController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final fees = admissionController.getFilteredPendingFees();

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
                      'Pending Admission Fees (0)',
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
                    'Pending Admission Fees (${fees.length})',
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
                      'Admission Date',
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
                      'Admission Fees',
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
                      'Paid Amount',
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
                        children: _buildAdmissionFeeCells(
                          fee,
                          admissionController,
                          context,
                        ),
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
      print('Error in PendingFeesView build: $e');
      print('Stack trace: $stackTrace');

      // Fallback UI for when controller is not available
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
            SizedBox(height: 16.h),
            Text(
              'Unable to load admission fees',
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

  List<Widget> _buildAdmissionFeeCells(
    AdmissionFeeModel fee,
    AdmissionFeesController controller,
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
          child: Text(
            fee.createdAt != null
                ? DateFormat('dd/MM/yyyy').format(fee.createdAt!)
                : 'No date',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            'PKR ${fee.amountDue.toStringAsFixed(0)}',
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
            'PKR ${fee.amountPaid.toStringAsFixed(0)}',
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
            'PKR ${fee.remainingAmount.toStringAsFixed(0)}',
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
                tooltip: 'Pay Fees',
                color: Colors.green[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () => _showAdmissionFeeDetailsDialog(fee),
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

  void _showAdmissionFeeDetailsDialog(AdmissionFeeModel fee) {
    Get.dialog(AdmissionFeeDetailsDialog(fee: fee), barrierDismissible: true);
  }

  void _showFeeDetailsDialog(BuildContext context, AdmissionFeeModel fee) {
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
                          'Admission Fee Details',
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
                          _buildDetailRow(
                            'Admission Date',
                            fee.createdAt != null
                                ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(fee.createdAt!)
                                : 'No date',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            'Total Amount',
                            'PKR ${fee.amountDue.toStringAsFixed(0)}',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            'Amount Paid',
                            'PKR ${fee.amountPaid.toStringAsFixed(0)}',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            'Remaining Amount',
                            'PKR ${fee.remainingAmount.toStringAsFixed(0)}',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow('Status', fee.status),
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
    AdmissionFeeModel fee,
    AdmissionFeesController controller,
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
                                'Pay Admission Fees',
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
                                    'PKR ${fee.amountDue.toStringAsFixed(0)}',
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
                                    'PKR ${fee.amountPaid.toStringAsFixed(0)}',
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
                                    'PKR ${fee.remainingAmount.toStringAsFixed(0)}',
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
                                        '${((fee.amountPaid / fee.amountDue) * 100).toStringAsFixed(1)}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: fee.amountPaid == fee.amountDue
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
                                        value: fee.amountDue > 0
                                            ? fee.amountPaid / fee.amountDue
                                            : 0.0,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              fee.amountPaid == fee.amountDue
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
                              _buildInfoRow('Class', 'Not Available'),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Admission Fees',
                                'PKR ${fee.amountDue.toStringAsFixed(0)}',
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Paid Fees',
                                'PKR ${fee.amountPaid.toStringAsFixed(0)}',
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Remaining Fees',
                                'PKR ${fee.remainingAmount.toStringAsFixed(0)}',
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
                                    await controller.processPayment(
                                      fee.id!,
                                      paymentAmount,
                                    );

                                    Get.back(); // Close dialog

                                    // Show success message
                                    Get.snackbar(
                                      'Payment Successful',
                                      'Payment of PKR ${paymentAmount.toStringAsFixed(0)} processed successfully',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 3),
                                    );
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
}
