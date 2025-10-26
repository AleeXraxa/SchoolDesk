import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/admission_fees_controller.dart';
import '../../../data/models/aggregated_student_payment_model.dart';
import '../service/challan_service.dart';
import 'package:intl/intl.dart';

class PaidFeesView extends StatelessWidget {
  const PaidFeesView({super.key});

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

        final aggregatedPayments =
            admissionController.aggregatedStudentPayments;

        if (aggregatedPayments.isEmpty) {
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
                      'Paid Admission Fees (0)',
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
                    'Paid Admission Fees (${aggregatedPayments.length})',
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
                      'Amount Paid',
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
                      'Payment Modes',
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
                      'Payment Date',
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
                  children: [
                    // Main aggregated payment records
                    ...List.generate(aggregatedPayments.length, (index) {
                      final aggregatedPayment = aggregatedPayments[index];
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
                          children: _buildAggregatedPaymentCells(
                            aggregatedPayment,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      });
    } catch (e, stackTrace) {
      // Log the error for debugging
      print('Error in PaidFeesView build: $e');
      print('Stack trace: $stackTrace');

      // Fallback UI for when controller is not available
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
            SizedBox(height: 16.h),
            Text(
              'Unable to load paid fees',
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

  List<Widget> _buildAggregatedPaymentCells(
    AggregatedStudentPaymentModel aggregatedPayment,
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
            aggregatedPayment.rollNo ?? 'N/A',
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
                aggregatedPayment.studentName ?? 'Unknown Student',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (aggregatedPayment.paymentCount > 1) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${aggregatedPayment.paymentCount} payments',
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
            aggregatedPayment.admissionDate != null
                ? DateFormat(
                    'dd/MM/yyyy',
                  ).format(aggregatedPayment.admissionDate!)
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
            'Rs. ${aggregatedPayment.totalPaidAmount.toStringAsFixed(0)}',
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
            'Multiple',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
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
            DateFormat(
              'dd/MM/yyyy',
            ).format(aggregatedPayment.mostRecentPaymentDate),
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _showPaymentDetailsDialog(aggregatedPayment),
                icon: Icon(Icons.visibility, size: 18.sp),
                tooltip: 'View Details',
                color: Colors.blue[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.all(6.w),
                ),
              ),
              SizedBox(width: 4.w),
              FutureBuilder<int>(
                future: ChallanService.getUnpaidFeeEntriesCount(
                  aggregatedPayment.studentId.toString(),
                ),
                builder: (context, snapshot) {
                  final unpaidCount = snapshot.data ?? 0;
                  final hasChallan =
                      unpaidCount ==
                      0; // If count is 0, all are paid (challan exists)

                  return IconButton(
                    onPressed: hasChallan
                        ? null
                        : () async {
                            if (unpaidCount == 1) {
                              // Single entry - generate directly
                              final success =
                                  await ChallanService.generateSingleChallan(
                                    studentId: aggregatedPayment.studentId
                                        .toString(),
                                    classId:
                                        null, // Aggregated payment doesn't have classId
                                    feesType: 'Admission',
                                    amount: aggregatedPayment.totalPaidAmount,
                                    referenceFeeId: aggregatedPayment.studentId
                                        .toString(),
                                    month: DateFormat(
                                      'MMMM yyyy',
                                    ).format(DateTime.now()),
                                    datePaid:
                                        aggregatedPayment.mostRecentPaymentDate,
                                    paymentMode:
                                        'Multiple', // Since it's aggregated
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
                              _showCombinedChallanDialog(
                                context,
                                aggregatedPayment,
                              );
                            }
                          },
                    icon: Icon(
                      hasChallan ? Icons.check_circle : Icons.receipt_long,
                      size: 18.sp,
                    ),
                    tooltip: hasChallan
                        ? 'Challan Already Generated'
                        : 'Generate Challan',
                    color: hasChallan ? Colors.green[600] : Colors.orange[600],
                    style: IconButton.styleFrom(
                      backgroundColor: hasChallan
                          ? Colors.green[50]
                          : Colors.orange[50],
                      padding: EdgeInsets.all(6.w),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showCombinedChallanDialog(
    BuildContext context,
    AggregatedStudentPaymentModel aggregatedPayment,
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
                                aggregatedPayment.studentName ?? 'Unknown',
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
                                'Rs. ${aggregatedPayment.totalPaidAmount.toStringAsFixed(0)}',
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
                                aggregatedPayment.individualPayments.length,
                            onChanged: (value) {
                              if (value == true) {
                                selectedEntries.value = aggregatedPayment
                                    .individualPayments
                                    .map(
                                      (payment) => {
                                        'id': payment.id,
                                        'amount': payment.amountPaid,
                                        'payment_date': payment.paymentDate,
                                        'mode_of_payment':
                                            payment.modeOfPayment,
                                        'fees_type': 'Admission',
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
                          itemCount:
                              aggregatedPayment.individualPayments.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey[200], height: 1),
                          itemBuilder: (context, index) {
                            final payment =
                                aggregatedPayment.individualPayments[index];

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
                                                          payment.amountPaid,
                                                      'payment_date':
                                                          payment.paymentDate,
                                                      'mode_of_payment':
                                                          payment.modeOfPayment,
                                                      'fees_type': 'Admission',
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
                                                'Rs. ${payment.amountPaid.toStringAsFixed(0)} - ${payment.modeOfPayment}',
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
                                            studentId: aggregatedPayment
                                                .studentId
                                                .toString(),
                                            classId: null,
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

  void _showPaymentDetailsDialog(
    AggregatedStudentPaymentModel aggregatedPayment,
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
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.blue[600],
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Payment Details',
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
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
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Student Name',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                aggregatedPayment.studentName ?? 'Unknown',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Roll No',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                aggregatedPayment.rollNo ?? 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
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
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Rs. ${aggregatedPayment.totalPaidAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Individual Payments Header
                    Text(
                      'Individual Payments (${aggregatedPayment.paymentCount})',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Individual Payments List
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount:
                              aggregatedPayment.individualPayments.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey[200], height: 1),
                          itemBuilder: (context, index) {
                            final payment =
                                aggregatedPayment.individualPayments[index];
                            return Container(
                              padding: EdgeInsets.all(12.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(payment.paymentDate),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Rs. ${payment.amountPaid.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        payment.modeOfPayment,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 45.h,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
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
}
