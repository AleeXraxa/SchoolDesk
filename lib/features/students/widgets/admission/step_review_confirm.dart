import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controller/new_admission_controller.dart';

class StepReviewConfirm extends GetView<NewAdmissionController> {
  const StepReviewConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review & Confirm',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Please review all information before submitting',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Personal Details Card
          _buildReviewCard(
            'Personal Details',
            Icons.person,
            Colors.blue,
            _buildPersonalDetails(),
            onEdit: () => controller.goToStep(0),
          ),
          SizedBox(height: 16.h),

          // Class Assignment Card
          _buildReviewCard(
            'Class Assignment',
            Icons.class_,
            Colors.purple,
            _buildClassDetails(),
            onEdit: () => controller.goToStep(1),
          ),
          SizedBox(height: 16.h),

          // Fees Details Card
          _buildReviewCard(
            'Fees Configuration',
            Icons.attach_money,
            Colors.orange,
            _buildFeesDetails(),
            onEdit: () => controller.goToStep(2),
          ),
          SizedBox(height: 24.h),

          // Important Notice
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber[800],
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Important Notice',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please ensure all information is correct. Once submitted, the admission process will be initiated and fees will be non-refundable.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.amber[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String title,
    IconData icon,
    Color color,
    Widget content, {
    VoidCallback? onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit, color: color, size: 18.sp),
                    tooltip: 'Edit $title',
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(Size(32.w, 32.h)),
                  ),
              ],
            ),
          ),
          // Content
          Padding(padding: EdgeInsets.all(16.w), child: content),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return Column(
      children: [
        _buildReviewRow('Roll No', controller.rollNoController.text),
        _buildReviewRow('GR No', controller.grNoController.text),
        _buildReviewRow('Student Name', controller.studentNameController.text),
        _buildReviewRow('Father\'s Name', controller.fatherNameController.text),
        if (controller.casteController.text.isNotEmpty)
          _buildReviewRow('Caste', controller.casteController.text),
        _buildReviewRow(
          'Place of Birth',
          controller.placeOfBirthController.text,
        ),
        _buildReviewRow('Date of Birth', controller.dateOfBirthInWords.value),
        _buildReviewRow('Gender', controller.selectedGender.value),
        _buildReviewRow('Religion', controller.selectedReligion.value),
        _buildReviewRow(
          'Father\'s Contact',
          controller.fathersContactController.text,
        ),
        if (controller.mothersContactController.text.isNotEmpty)
          _buildReviewRow(
            'Mother\'s Contact',
            controller.mothersContactController.text,
          ),
        _buildReviewRow(
          'Address',
          controller.addressController.text,
          isMultiline: true,
        ),
      ],
    );
  }

  Widget _buildClassDetails() {
    return Column(
      children: [
        _buildReviewRow('Class', controller.selectedClass.value),
        _buildReviewRow('Section', controller.selectedSection.value),
      ],
    );
  }

  Widget _buildFeesDetails() {
    final admissionFees =
        double.tryParse(controller.admissionFeesController.text) ?? 0.0;
    final monthlyFees =
        double.tryParse(controller.monthlyFeesController.text) ?? 0.0;
    final total = admissionFees + monthlyFees;

    return Column(
      children: [
        _buildReviewRow(
          'Admission Fees',
          'PKR ${admissionFees.toStringAsFixed(2)}',
        ),
        _buildReviewRow(
          'Monthly Fees',
          'PKR ${monthlyFees.toStringAsFixed(2)}',
        ),
        Divider(height: 16.h, color: Colors.grey.withOpacity(0.2)),
        _buildReviewRow(
          'Total',
          'PKR ${total.toStringAsFixed(2)}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildReviewRow(
    String label,
    String value, {
    bool isMultiline = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isTotal ? 13.sp : 12.sp,
                color: isTotal ? Colors.orange[800] : Colors.black87,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
