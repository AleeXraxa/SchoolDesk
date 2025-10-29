import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/monthly_fees_controller.dart';
import '../../../data/models/monthly_paid_fees_model.dart';
import 'monthly_fee_details_dialog.dart';
import '../service/challan_service.dart';
import '../../../data/database_service.dart';
import 'package:intl/intl.dart';

class MonthlyPaidFeesView extends StatelessWidget {
  const MonthlyPaidFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    final MonthlyFeesController controller = Get.find();

    return Obx(() {
      final fees = controller.getDisplayedAggregatedPaidFees();

      if (fees.isEmpty) {
        return Column(
          children: [
            // Header - Always show header to maintain consistent layout
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Paid Monthly Fees (0)',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
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
                      Icons.check_circle_outline,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      controller.isViewFiltered.value
                          ? 'No records found for ${controller.selectedClass.value} - ${controller.selectedMonth.value}'
                          : 'No records found',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
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
              color: Colors.green[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Paid Monthly Fees (${fees.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
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
                    'Class',
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
                    'Total Paid',
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
                    'Last Payment',
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
                      children: _buildAggregatedMonthlyFeeCells(
                        fee,
                        controller,
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
  }

  List<Widget> _buildAggregatedMonthlyFeeCells(
    MonthlyPaidFeesModel fee,
    MonthlyFeesController controller,
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
          child: Row(
            children: [
              Text(
                fee.studentName ?? 'Unknown Student',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (fee.paymentCount > 1) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${fee.paymentCount} entries',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            '${fee.className ?? 'N/A'} ${fee.section ?? ''}'.trim(),
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
            fee.formattedTotalPaid,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
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
            fee.remainingAmount > 0
                ? 'PKR ${fee.remainingAmount.toStringAsFixed(0)}'
                : 'PKR 0',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
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
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Text(
            fee.formattedLastPaymentDate,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
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
                onPressed: () => _showMonthlyFeeDetailsDialog(fee),
                icon: Icon(Icons.visibility, size: 18.sp),
                tooltip: 'View Details',
                color: Colors.blue[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () async {
                  // For monthly fees, we need to get the actual student ID from the monthly fee record first
                  String actualStudentId;
                  if (fee.paymentCount == 1) {
                    final monthlyFeeId =
                        fee.individualPayments.first.monthlyFeeId;
                    print(
                      'DEBUG: Monthly fee - fee.studentId: ${fee.studentId}, monthlyFeeId: $monthlyFeeId',
                    );

                    // Query the monthly_fees table to get the actual student_id
                    final db = await DatabaseService.database;
                    final monthlyFeeResult = await db.query(
                      'monthly_fees',
                      where: 'id = ?',
                      whereArgs: [monthlyFeeId],
                      limit: 1,
                    );

                    if (monthlyFeeResult.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Could not find monthly fee record',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    actualStudentId = monthlyFeeResult.first['student_id']
                        .toString();
                    print('DEBUG: Found actual student ID: $actualStudentId');
                  } else {
                    // For multiple entries, we need to get the student ID from the first payment's monthly fee record
                    final firstMonthlyFeeId =
                        fee.individualPayments.first.monthlyFeeId;
                    final db = await DatabaseService.database;
                    final monthlyFeeResult = await db.query(
                      'monthly_fees',
                      where: 'id = ?',
                      whereArgs: [firstMonthlyFeeId],
                      limit: 1,
                    );

                    if (monthlyFeeResult.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Could not find monthly fee record',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    actualStudentId = monthlyFeeResult.first['student_id']
                        .toString();
                    print(
                      'DEBUG: Found actual student ID for multiple entries: $actualStudentId',
                    );
                  }

                  // Now check if student has remaining balance using the correct student ID
                  final remainingBalance =
                      await ChallanService.getRemainingBalance(
                        actualStudentId,
                        feesType: 'Monthly',
                      );

                  if (remainingBalance <= 0) {
                    Get.snackbar(
                      'Info',
                      'No outstanding balance for this student',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  if (fee.paymentCount == 1) {
                    // Single entry - generate challan for remaining balance
                    final success = await ChallanService.generateSingleChallan(
                      studentId:
                          actualStudentId, // Use the actual student ID from monthly fee record
                      classId: fee.className,
                      feesType: 'Monthly',
                      amount: remainingBalance, // Use remaining balance
                      referenceFeeId: fee.studentId.toString(),
                      month: fee.month,
                      datePaid: fee.mostRecentPaymentDate,
                      paymentMode: 'Multiple',
                    );

                    if (success) {
                      Get.snackbar(
                        'Success',
                        'Challan generated successfully!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        'Failed to generate challan. It may already exist.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  } else {
                    // Multiple entries - show selection dialog
                    _showCombinedChallanDialog(context, fee);
                  }
                },
                icon: Icon(Icons.receipt_long, size: 18.sp),
                tooltip: 'Generate Challan',
                color: Colors.orange[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showMonthlyFeeDetailsDialog(MonthlyPaidFeesModel fee) {
    Get.dialog(MonthlyFeeDetailsDialog(fee: fee), barrierDismissible: true);
  }

  void _showCombinedChallanDialog(
    BuildContext context,
    MonthlyPaidFeesModel fee,
  ) {
    final selectedEntries = <Map<String, dynamic>>[].obs;
    final remarksController = TextEditingController();

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
                width: MediaQuery.of(context).size.width > 600 ? 600.w : 500.w,
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
                            Icons.playlist_add_check,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Select Entries for Individual Challans',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Student Info
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Student',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                fee.studentName ?? 'Unknown',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Paid',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Rs. ${fee.totalPaidAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Select All Checkbox
                    Row(
                      children: [
                        Obx(
                          () => Checkbox(
                            value:
                                selectedEntries.length ==
                                fee.individualPayments.length,
                            onChanged: (value) {
                              if (value == true) {
                                selectedEntries.value = fee.individualPayments
                                    .map(
                                      (payment) => {
                                        'id': payment.id,
                                        'amount': payment.paidAmount,
                                        'payment_date': payment.paymentDate,
                                        'mode_of_payment': payment.paymentMode,
                                        'fees_type': 'Monthly',
                                      },
                                    )
                                    .toList();
                              } else {
                                selectedEntries.clear();
                              }
                            },
                          ),
                        ),
                        Text(
                          'Select All Entries',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Individual Payments List
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: fee.individualPayments.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey[200], height: 1),
                          itemBuilder: (context, index) {
                            final payment = fee.individualPayments[index];

                            // Check if this payment already has a challan
                            return FutureBuilder<bool>(
                              future: ChallanService.challanExistsForFee(
                                payment.id.toString(),
                              ),
                              builder: (context, snapshot) {
                                final hasChallan = snapshot.data ?? false;

                                return Obx(
                                  () => Container(
                                    padding: EdgeInsets.all(12.w),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: selectedEntries.any(
                                            (entry) =>
                                                entry['id'] == payment.id,
                                          ),
                                          onChanged: hasChallan
                                              ? null // Disable if challan already exists
                                              : (value) {
                                                  if (value == true) {
                                                    selectedEntries.add({
                                                      'id': payment.id,
                                                      'amount':
                                                          payment.paidAmount,
                                                      'payment_date':
                                                          payment.paymentDate,
                                                      'mode_of_payment':
                                                          payment.paymentMode,
                                                      'fees_type': 'Monthly',
                                                    });
                                                  } else {
                                                    selectedEntries.removeWhere(
                                                      (entry) =>
                                                          entry['id'] ==
                                                          payment.id,
                                                    );
                                                  }
                                                },
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                      'dd/MM/yyyy HH:mm',
                                                    ).format(
                                                      payment.paymentDate,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12.sp,
                                                      color: hasChallan
                                                          ? Colors.grey[500]
                                                          : Colors.black87,
                                                      decoration: hasChallan
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                    ),
                                                  ),
                                                  if (hasChallan) ...[
                                                    SizedBox(width: 8.w),
                                                    Icon(
                                                      Icons.check_circle,
                                                      size: 14.sp,
                                                      color: Colors.green[600],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text(
                                                'Rs. ${payment.paidAmount.toStringAsFixed(0)} - ${payment.paymentMode}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11.sp,
                                                  color: hasChallan
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                  decoration: hasChallan
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                              ),
                                              if (hasChallan)
                                                Text(
                                                  'Challan already generated',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10.sp,
                                                    color: Colors.green[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Remarks Field
                    TextFormField(
                      controller: remarksController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Remarks (Optional)',
                        hintText: 'Add any additional notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),

                    SizedBox(height: 24.h),

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
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: selectedEntries.isEmpty
                                  ? null
                                  : () async {
                                      final totalAmount = selectedEntries
                                          .fold<double>(
                                            0.0,
                                            (sum, entry) =>
                                                sum +
                                                (entry['amount'] as double),
                                          );

                                      final referenceFeeIds = selectedEntries
                                          .map(
                                            (entry) => entry['id'].toString(),
                                          )
                                          .toList();

                                      final success =
                                          await ChallanService.generateSeparateChallans(
                                            studentId: fee.studentId.toString(),
                                            classId: fee.className,
                                            selectedEntries: selectedEntries,
                                            remarks:
                                                remarksController
                                                    .text
                                                    .isNotEmpty
                                                ? remarksController.text
                                                : null,
                                          );

                                      Get.back(); // Close dialog

                                      if (success) {
                                        Get.snackbar(
                                          'Success',
                                          'Individual challans generated successfully!',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                      } else {
                                        Get.snackbar(
                                          'Error',
                                          'Failed to generate individual challans.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
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
                                'Generate Challan (${selectedEntries.length})',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
