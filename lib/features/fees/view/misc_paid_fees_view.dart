import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/misc_fees_controller.dart';
import '../../../data/models/misc_paid_fee_model.dart';
import 'misc_fee_details_dialog.dart';

class MiscPaidFeesView extends StatelessWidget {
  const MiscPaidFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MiscFeesController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final fees = controller.isViewFiltered.value
          ? controller.getFilteredAggregatedPaidFeesForView()
          : controller.getDisplayedAggregatedPaidFees();

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
                    'Paid Misc Fees (0)',
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
                Icon(Icons.check_circle, color: Colors.green[700], size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Paid Misc Fees (${fees.length})',
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
                    'Fee Details',
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
                      children: _buildMiscPaidFeeCells(
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

  List<Widget> _buildMiscPaidFeeCells(
    MiscPaidFeeModel fee,
    MiscFeesController controller,
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
                fee.miscFeeType ?? 'N/A',
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
            'PKR ${fee.paidAmount.toStringAsFixed(0)}',
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
            DateFormat('dd/MM/yyyy').format(fee.paymentDate),
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey[700],
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
            'PKR ${(fee.remainingAmount ?? 0.0).toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: (fee.remainingAmount ?? 0.0) > 0
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
                onPressed: () => _showMiscFeeDetailsDialog(fee),
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

  void _showMiscFeeDetailsDialog(MiscPaidFeeModel fee) {
    Get.dialog(MiscFeeDetailsDialog(fee: fee), barrierDismissible: true);
  }
}
