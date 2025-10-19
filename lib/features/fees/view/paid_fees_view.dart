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

        final fees = admissionController.getFilteredPaidFees();

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
                    'Paid Admission Fees (${fees.length})',
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
                      child: Row(children: _buildAdmissionFeeCells(fee)),
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

  void _showAdmissionFeeDetailsDialog(AdmissionFeeModel fee) {
    Get.dialog(AdmissionFeeDetailsDialog(fee: fee), barrierDismissible: true);
  }

  List<Widget> _buildAdmissionFeeCells(AdmissionFeeModel fee) {
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
            'Rs. ${fee.amountDue.toStringAsFixed(0)}',
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
            'Rs. ${fee.amountPaid.toStringAsFixed(0)}',
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
            'Rs. ${fee.remainingAmount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: fee.remainingAmount == 0
                  ? Colors.green[700]
                  : Colors.orange[700],
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
                onPressed: () => _showAdmissionFeeDetailsDialog(fee),
                icon: Icon(Icons.visibility, size: 20.sp),
                tooltip: 'View Details',
                color: Colors.blue[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.all(8.w),
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.receipt, size: 20.sp),
                tooltip: 'View Receipt',
                color: Colors.purple[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.purple[50],
                  padding: EdgeInsets.all(8.w),
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.print, size: 20.sp),
                tooltip: 'Print Receipt',
                color: Colors.teal[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.teal[50],
                  padding: EdgeInsets.all(8.w),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
