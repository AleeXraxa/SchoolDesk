import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/new_admission_controller.dart';
import 'custom_text_field.dart';

class StepFeesAmount extends GetView<NewAdmissionController> {
  const StepFeesAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.feesFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.orange, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fees Configuration',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Set admission and monthly fees for the student',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Admission Fees
            CustomTextField(
              controller: controller.admissionFeesController,
              label: 'Admission Fees (PKR)',
              hint: 'Enter admission fees amount',
              icon: Icons.account_balance_wallet,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) =>
                  controller.validatePositiveNumber(value, 'Admission fees'),
              onChanged: (value) => controller.update(),
            ),
            SizedBox(height: 16.h),

            // Monthly Fees
            CustomTextField(
              controller: controller.monthlyFeesController,
              label: 'Monthly Fees (PKR)',
              hint: 'Enter monthly fees amount',
              icon: Icons.calendar_month,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) =>
                  controller.validatePositiveNumber(value, 'Monthly fees'),
              onChanged: (value) => controller.update(),
            ),
            SizedBox(height: 24.h),

            // Summary Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.purple,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Fees Summary',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  GetBuilder<NewAdmissionController>(
                    builder: (controller) {
                      final admissionFees =
                          double.tryParse(
                            controller.admissionFeesController.text,
                          ) ??
                          0.0;
                      final monthlyFees =
                          double.tryParse(
                            controller.monthlyFeesController.text,
                          ) ??
                          0.0;
                      final total = admissionFees + monthlyFees;

                      return Column(
                        children: [
                          _buildSummaryRow(
                            'Admission Fees',
                            'PKR ${admissionFees.toStringAsFixed(2)}',
                          ),
                          SizedBox(height: 8.h),
                          _buildSummaryRow(
                            'Monthly Fees',
                            'PKR ${monthlyFees.toStringAsFixed(2)}',
                          ),
                          SizedBox(height: 8.h),
                          Divider(color: Colors.purple.withOpacity(0.2)),
                          SizedBox(height: 8.h),
                          _buildSummaryRow(
                            'Total',
                            'PKR ${total.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Important Note
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[800],
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Note: Fees is non refundable.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.amber[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 13.sp : 12.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.purple[800] : Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 13.sp : 12.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.purple[800] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
