import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database_service.dart';
import '../service/challan_service.dart';
import '../service/challan_print_service.dart';
import '../service/combined_challan_service.dart';

class MultipleChallanView extends StatelessWidget {
  const MultipleChallanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Generate Challan Button
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.playlist_add_check,
                      color: Colors.blue[600],
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multiple Challans',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Generate individual challans for multiple paid fees',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showGenerateChallanDialog(context),
                    icon: Icon(Icons.add_circle, size: 20.sp),
                    label: Text(
                      'Generate Challan',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Instructions Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'How to Generate Multiple Challans',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildInstructionStep(
                    '1',
                    'Click the "Generate Challan" button above',
                  ),
                  SizedBox(height: 8.h),
                  _buildInstructionStep(
                    '2',
                    'Select a month from the dropdown',
                  ),
                  SizedBox(height: 8.h),
                  _buildInstructionStep('3', 'Enter student roll number'),
                  SizedBox(height: 8.h),
                  _buildInstructionStep(
                    '4',
                    'Review and select paid fees to include',
                  ),
                  SizedBox(height: 8.h),
                  _buildInstructionStep(
                    '5',
                    'Click "Generate Challans" to create individual challans',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Combined Challans List
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.list_alt,
                          color: Colors.green[600],
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          'Generated Combined Challans',
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
                  _buildCombinedChallansTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String step, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showGenerateChallanDialog(BuildContext context) {
    final selectedMonth = Rx<String>('');
    final studentIdController = TextEditingController();
    final rollSearchQuery = ''.obs;
    final studentSearchResults = <Map<String, dynamic>>[].obs;
    final suppressRollSearchChange = false.obs;
    final selectedEntries = <Map<String, dynamic>>[].obs;
    final isLoading = false.obs;
    final paidEntries = <Map<String, dynamic>>[].obs;
    final foundStudentData = Rx<Map<String, dynamic>?>(null);

    // Debug: Fetch all students when dialog opens
    _debugFetchAllStudents();

    // Generate months for the last 12 months
    final months = List.generate(12, (index) {
      final date = DateTime.now().subtract(Duration(days: index * 30));
      return DateFormat('MMMM yyyy').format(date);
    }).toSet().toList(); // Remove duplicates

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
                width: MediaQuery.of(context).size.width > 800 ? 700.w : 600.w,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.playlist_add_check,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Generate Multiple Challans',
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

                    // Student Roll No Search
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Roll No',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: studentIdController,
                            onChanged: (value) async {
                              if (suppressRollSearchChange.value) return;
                              rollSearchQuery.value = value.trim();
                              // Any roll number change invalidates previously fetched state.
                              paidEntries.clear();
                              selectedEntries.clear();
                              foundStudentData.value = null;

                              if (rollSearchQuery.value.isEmpty) {
                                studentSearchResults.clear();
                                return;
                              }

                              final results = await _searchStudentsByRollNoLike(
                                rollSearchQuery.value,
                              );
                              studentSearchResults.value = results;
                            },
                            decoration: InputDecoration(
                              hintText: 'Type roll no e.g. 01 or BMS-00001',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                            ),
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),

                          SizedBox(height: 8.h),

                          Obx(
                            () => studentSearchResults.isNotEmpty
                                ? Container(
                                    constraints: BoxConstraints(maxHeight: 180.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: studentSearchResults.length,
                                      separatorBuilder: (_, __) => Divider(
                                        height: 1,
                                        color: Colors.grey[200],
                                      ),
                                      itemBuilder: (context, index) {
                                        final student =
                                            studentSearchResults[index];
                                        final roll =
                                            student['roll_no']?.toString() ?? '';
                                        final name =
                                            student['student_name']?.toString() ??
                                                'Unknown';
                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            roll,
                                            style: GoogleFonts.inter(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            name,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          onTap: () {
                                            suppressRollSearchChange.value =
                                                true;
                                            foundStudentData.value = student;
                                            studentIdController.text = roll;
                                            rollSearchQuery.value = roll;
                                            studentSearchResults.clear();
                                            paidEntries.clear();
                                            selectedEntries.clear();
                                            suppressRollSearchChange.value =
                                                false;
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : (rollSearchQuery.value.isNotEmpty &&
                                          foundStudentData.value == null
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: Text(
                                            'No matching student found',
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              color: Colors.red[600],
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink()),
                          ),

                          Obx(
                            () => foundStudentData.value != null
                                ? Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      'Selected: ${foundStudentData.value!['student_name']} (${foundStudentData.value!['roll_no']})',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Month Selector
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Month',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: selectedMonth.value.isEmpty
                                  ? null
                                  : selectedMonth.value,
                              decoration: InputDecoration(
                                hintText: 'Choose a month',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                              ),
                              items: months.map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    month,
                                    style: GoogleFonts.inter(fontSize: 14.sp),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedMonth.value = value ?? '';
                                // Clear previous fetched entries when month changes.
                                paidEntries.clear();
                                selectedEntries.clear();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Fetch Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed:
                              selectedMonth.value.isEmpty ||
                                  foundStudentData.value == null
                              ? null
                              : () async {
                                  // Reset prior selection before a fresh fetch.
                                  selectedEntries.clear();
                                  paidEntries.clear();
                                  final selectedStudent =
                                      foundStudentData.value;
                                  final studentId = int.tryParse(
                                    selectedStudent?['id']?.toString() ?? '',
                                  );
                                  if (studentId == null) {
                                    Get.snackbar(
                                      'Error',
                                      'Please select a valid student from the list.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  isLoading.value = true;
                                  try {
                                    await _fetchPaidEntries(
                                      selectedMonth.value,
                                      studentId,
                                      paidEntries,
                                    );
                                  } finally {
                                    isLoading.value = false;
                                  }
                                },
                          icon: Icon(
                            isLoading.value
                                ? Icons.hourglass_empty
                                : Icons.search,
                            size: 20.sp,
                          ),
                          label: Text(
                            isLoading.value
                                ? 'Fetching...'
                                : 'Fetch Paid Entries',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Paid Entries Section
                    Obx(
                      () => paidEntries.isNotEmpty
                          ? Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey[200]!),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  children: [
                                    // Header
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12.r),
                                          topRight: Radius.circular(12.r),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Select Entries for Challans',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const Spacer(),
                                          Obx(
                                            () => Text(
                                              '${selectedEntries.length} selected',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Entries List
                                    Flexible(
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: paidEntries.length,
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                              color: Colors.grey[200],
                                              height: 1,
                                            ),
                                        itemBuilder: (context, index) {
                                          final entry = paidEntries[index];
                                          final entryKey = _getEntrySelectionKey(
                                            entry,
                                          );
                                          return Obx(
                                            () => Container(
                                              padding: EdgeInsets.all(12.w),
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: selectedEntries.any(
                                                      (selected) =>
                                                          _getEntrySelectionKey(
                                                            selected,
                                                          ) ==
                                                          entryKey,
                                                    ),
                                                    onChanged: (value) {
                                                      if (value == true) {
                                                        final alreadySelected =
                                                            selectedEntries.any(
                                                              (selected) =>
                                                                  _getEntrySelectionKey(
                                                                    selected,
                                                                  ) ==
                                                                  entryKey,
                                                            );
                                                        if (!alreadySelected) {
                                                          selectedEntries.add(
                                                            entry,
                                                          );
                                                        }
                                                      } else {
                                                        selectedEntries
                                                            .removeWhere(
                                                              (selected) =>
                                                                  _getEntrySelectionKey(
                                                                    selected,
                                                                  ) ==
                                                                  entryKey,
                                                            );
                                                      }
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              DateFormat(
                                                                'dd/MM/yyyy HH:mm',
                                                              ).format(
                                                                entry['payment_date']
                                                                    as DateTime,
                                                              ),
                                                              style: GoogleFonts.inter(
                                                                fontSize: 12.sp,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 8.w,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        6.w,
                                                                    vertical:
                                                                        2.h,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: _getFeeTypeColor(
                                                                  entry['fees_type'],
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8.r,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                entry['fees_type'],
                                                                style: GoogleFonts.inter(
                                                                  fontSize:
                                                                      10.sp,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          'Rs. ${entry['amount'].toStringAsFixed(0)} - ${entry['mode_of_payment']}',
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontSize: 11.sp,
                                                                color: Colors
                                                                    .grey[600],
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
                                      ),
                                    ),

                                    // Total Summary
                                    Obx(
                                      () => Container(
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.r),
                                            bottomRight: Radius.circular(12.r),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Selected Entries: ${selectedEntries.length}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                            Text(
                                              'Total: Rs. ${selectedEntries.fold<double>(0.0, (sum, entry) => sum + ((entry['amount'] as num?)?.toDouble() ?? 0.0)).toStringAsFixed(0)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Center(
                                child: Text(
                                  'Select student and month, then click "Fetch Paid Entries"',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ),

                    SizedBox(height: 24.h),

                    // Action Buttons
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
                            () {
                              final studentData = foundStudentData.value;
                              final studentId = int.tryParse(
                                studentData?['id']?.toString() ?? '',
                              );
                              final canGenerate =
                                  selectedEntries.isNotEmpty &&
                                  selectedMonth.value.isNotEmpty &&
                                  studentId != null;

                              return ElevatedButton(
                                onPressed: !canGenerate
                                    ? null
                                    : () async {
                                        final safeStudentId = int.tryParse(
                                          foundStudentData.value?['id']
                                                  ?.toString() ??
                                              '',
                                        );
                                        if (safeStudentId == null) {
                                          Get.snackbar(
                                            'Error',
                                            'Student data is invalid. Please fetch paid entries again.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        // Show option dialog for individual vs combined challans
                                        _showChallanTypeDialog(
                                          context,
                                          selectedMonth.value,
                                          safeStudentId,
                                          selectedEntries
                                              .map((e) => Map<String, dynamic>.from(e))
                                              .toList(),
                                        );
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
                                'Generate Challans (${selectedEntries.length})',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              );
                            },
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

  Future<void> _debugFetchAllStudents() async {
    try {
      final db = await DatabaseService.database;
      final students = await db.query('students');

      print('=== DEBUG: All Students in Database ===');
      print('Total students found: ${students.length}');
      for (var student in students) {
        print(
          'ID: ${student['id']}, Roll No: ${student['roll_no']}, Name: ${student['student_name']}',
        );
      }
      print('=======================================');
    } catch (e) {
      print('Error fetching students for debug: $e');
    }
  }

  Future<Map<String, dynamic>?> _checkStudentByRollNo(String rollNo) async {
    try {
      final db = await DatabaseService.database;
      final studentResult = await db.query(
        'students',
        where: 'roll_no = ?',
        whereArgs: [rollNo.trim()],
        limit: 1,
      );

      if (studentResult.isNotEmpty) {
        final student = studentResult.first;
        print('✅ DEBUG: Student FOUND for Roll No: $rollNo');
        print('   Student ID: ${student['id']}');
        print('   Student Name: ${student['student_name']}');
        print('   Roll No: ${student['roll_no']}');

        Get.snackbar(
          'Student Found',
          'Roll No: $rollNo → Student: ${student['student_name']} (ID: ${student['id']})',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return student;
      } else {
        print('❌ DEBUG: Student NOT FOUND for Roll No: $rollNo');
        print('   Searched roll_no: "${rollNo.trim()}"');

        Get.snackbar(
          'Student Not Found',
          'No student found with roll number: $rollNo',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return null;
      }
    } catch (e) {
      print('Error checking student by roll no: $e');
      Get.snackbar(
        'Error',
        'Failed to check student: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> _fetchPaidEntries(
    String selectedMonth,
    int studentId,
    RxList<Map<String, dynamic>> paidEntries,
  ) async {
    try {
      final db = await DatabaseService.database;

      print('=== DEBUG: Fetching paid entries ===');
      print('Student ID: "$studentId"');

      // Parse the selected month to get year and month
      final monthDate = DateFormat('MMMM yyyy').parse(selectedMonth);
      final year = monthDate.year;
      final month = monthDate.month;

      // Fetch from all paid fee tables
      final admissionPayments = await db.rawQuery(
        '''
        SELECT
          paf.id,
          paf.amount_paid as amount,
          paf.payment_date,
          paf.mode_of_payment,
          'Admission' as fees_type,
          paf.student_id
        FROM paid_admission_fees paf
        WHERE paf.student_id = ?
          AND strftime('%Y', paf.payment_date) = ?
          AND strftime('%m', paf.payment_date) = ?
      ''',
        [studentId, year.toString(), month.toString().padLeft(2, '0')],
      );

      final monthlyPayments = await db.rawQuery(
        '''
        SELECT
          mph.id,
          mph.paid_amount as amount,
          mph.payment_date,
          mph.payment_mode as mode_of_payment,
          'Monthly' as fees_type,
          mf.student_id
        FROM monthly_payment_history mph
        LEFT JOIN monthly_fees mf ON mph.monthly_fee_id = mf.id
        WHERE mf.student_id = ?
          AND strftime('%Y', mph.payment_date) = ?
          AND strftime('%m', mph.payment_date) = ?
      ''',
        [studentId, year.toString(), month.toString().padLeft(2, '0')],
      );

      final examPayments = await db.rawQuery(
        '''
        SELECT
          efp.id,
          efp.paid_amount as amount,
          efp.payment_date,
          efp.payment_mode as mode_of_payment,
          'Exam' as fees_type,
          efp.student_id
        FROM exam_fees_paid efp
        WHERE efp.student_id = ?
          AND strftime('%Y', efp.payment_date) = ?
          AND strftime('%m', efp.payment_date) = ?
      ''',
        [studentId, year.toString(), month.toString().padLeft(2, '0')],
      );

      final miscPayments = await db.rawQuery(
        '''
        SELECT
          mfp.id,
          mfp.paid_amount as amount,
          mfp.payment_date,
          mfp.payment_mode as mode_of_payment,
          'Misc' as fees_type,
          mfp.student_id
        FROM misc_fees_paid mfp
        WHERE mfp.student_id = ?
          AND strftime('%Y', mfp.payment_date) = ?
          AND strftime('%m', mfp.payment_date) = ?
      ''',
        [studentId, year.toString(), month.toString().padLeft(2, '0')],
      );

      // Combine all payments
      final allPayments = [
        ...admissionPayments,
        ...monthlyPayments,
        ...examPayments,
        ...miscPayments,
      ];

      // Convert to the expected format
      paidEntries.value = allPayments.map((payment) {
        final feeType = payment['fees_type'] as String? ?? 'Unknown';
        final paymentId = payment['id']?.toString() ?? '';
        final paymentDateRaw = payment['payment_date'] as String? ?? '';
        final paymentDate = DateTime.parse(paymentDateRaw);
        final entryKey = '$feeType|$paymentId|$paymentDateRaw';
        return {
          'id': paymentId,
          'amount': (payment['amount'] as num).toDouble(),
          'payment_date': paymentDate,
          'payment_date_raw': paymentDateRaw,
          'mode_of_payment': payment['mode_of_payment'] as String,
          'fees_type': feeType,
          'entry_key': entryKey,
        };
      }).toList();

      print(
        'Fetched ${paidEntries.length} paid entries for student ID: $studentId in $selectedMonth',
      );
    } catch (e) {
      print('Error fetching paid entries: $e');
      paidEntries.clear();
      Get.snackbar(
        'Error',
        'Failed to fetch paid entries',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _searchStudentsByRollNoLike(
    String query,
  ) async {
    try {
      final db = await DatabaseService.database;
      return await db.query(
        'students',
        where: "roll_no IS NOT NULL AND roll_no != '' AND LOWER(roll_no) LIKE ?",
        whereArgs: ['%${query.toLowerCase()}%'],
        orderBy: 'roll_no ASC',
        limit: 20,
      );
    } catch (e) {
      print('Error searching students by roll no: $e');
      return [];
    }
  }

  String _getEntrySelectionKey(Map<String, dynamic> entry) {
    final fromStoredKey = entry['entry_key']?.toString();
    if (fromStoredKey != null && fromStoredKey.isNotEmpty) {
      return fromStoredKey;
    }

    final feeType = entry['fees_type']?.toString() ?? 'Unknown';
    final id = entry['id']?.toString() ?? '';
    final paymentDateRaw =
        entry['payment_date_raw']?.toString() ??
        entry['payment_date']?.toString() ??
        '';
    return '$feeType|$id|$paymentDateRaw';
  }

  Color _getFeeTypeColor(String feeType) {
    switch (feeType) {
      case 'Admission':
        return Colors.blue[600]!;
      case 'Monthly':
        return Colors.green[600]!;
      case 'Exam':
        return Colors.orange[600]!;
      case 'Misc':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildCombinedChallansTable() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCombinedChallans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading combined challans',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final combinedChallans = snapshot.data ?? [];

        if (combinedChallans.isEmpty) {
          return Container(
            height: 150.h,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No combined challans generated yet',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
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
                      'Challan ID',
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
                      'Month',
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
                      'Amount',
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
                      'Status',
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
            Container(
              constraints: BoxConstraints(maxHeight: 400.h),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(combinedChallans.length, (index) {
                    final challan = combinedChallans[index];
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
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                challan['id'].toString(),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              child: Text(
                                challan['student_name'] ?? 'Unknown Student',
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              child: Text(
                                challan['month'] ?? 'N/A',
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              child: Text(
                                'Rs. ${challan['total_amount'].toStringAsFixed(0)}',
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: challan['status'] == 'Paid'
                                      ? Colors.green[50]
                                      : Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  challan['status'] ?? 'Pending',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: challan['status'] == 'Paid'
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 6.h,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _showCombinedChallanDetails(challan),
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
                                    onPressed: () =>
                                        _showPrintChallanDialogForMultiple(
                                          challan,
                                          context,
                                        ),
                                    icon: Icon(Icons.print, size: 18.sp),
                                    tooltip: 'Print Challan',
                                    color: Colors.green[600],
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.green[50],
                                      padding: EdgeInsets.all(6.w),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCombinedChallans() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery('''
        SELECT
          mc.*,
          s.student_name,
          s.roll_no
        FROM multiple_challans mc
        LEFT JOIN students s ON mc.student_id = s.id
        ORDER BY mc.generated_date DESC
      ''');

      print('Fetched ${results.length} combined challans');
      for (var result in results) {
        print(
          'Challan ID: ${result['id']}, Stored student_id: ${result['student_id']}, Student Name: ${result['student_name']}, Roll No: ${result['roll_no']}',
        );
      }
      return results;
    } catch (e) {
      print('Error fetching combined challans: $e');
      return [];
    }
  }

  void _showCombinedChallanDetails(Map<String, dynamic> challan) {
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
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Combined Challan Details',
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

                    // Challan Info
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
                                'Challan ID',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '#${challan['id']}',
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
                                'Student',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${challan['student_name'] ?? 'Unknown Student'} (${challan['roll_no'] ?? 'N/A'})',
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
                                'Month',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                challan['month'],
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
                                'Total Amount',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Rs. ${challan['total_amount'].toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.green[700],
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
                                'Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: challan['status'] == 'Paid'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  challan['status'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: challan['status'] == 'Paid'
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Generated Date',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(
                                  DateTime.parse(challan['generated_date']),
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Selected Fees Details
                    Text(
                      'Selected Fee Entries',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 200.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: _buildSelectedFeesList(
                          challan['selected_fees_details'],
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

  Widget _buildSelectedFeesList(String? feesDetailsJson) {
    if (feesDetailsJson == null || feesDetailsJson.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'No fee details available',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        ),
      );
    }

    try {
      // Parse JSON array

      // Parse JSON array
      final List<dynamic> feesList = jsonDecode(feesDetailsJson);

      if (feesList.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'No fee entries found',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        itemCount: feesList.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey[200], height: 1),
        itemBuilder: (context, index) {
          final fee = feesList[index] as Map<String, dynamic>;

          final type = fee['type'] as String? ?? 'Unknown';
          final amount = (fee['amount'] as num?)?.toDouble() ?? 0.0;
          final dateString = fee['date'] as String?;

          DateTime? paymentDate;
          try {
            if (dateString != null) {
              paymentDate = DateTime.parse(dateString);
            }
          } catch (e) {
            // Invalid date format, keep as null
          }

          return Container(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Fee Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getFeeTypeColor(type),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Fee Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$type Fee Entry',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (paymentDate != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(paymentDate),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount
                Text(
                  'Rs. ${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Fallback: display as plain text
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Text(
            feesDetailsJson,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      );
    }
  }

  void _showChallanTypeDialog(
    BuildContext context,
    String selectedMonth,
    int studentId,
    List<Map<String, dynamic>> selectedEntries,
  ) {
    final studentIdController = TextEditingController(
      text: studentId.toString(),
    );
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
                    // Header
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.call_split,
                        color: AppColors.primary,
                        size: 30.sp,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      'Choose Challan Type',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'How would you like to generate the challans?',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24.h),

                    // Individual Challans Option
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: Colors.blue[600],
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Individual Challans',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create separate challan for each selected payment entry',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Get.back(); // Close type selection dialog
                                Get.back(); // Close main dialog

                                final success =
                                    await ChallanService.generateSeparateChallans(
                                      studentId: studentId.toString(),
                                      classId: null,
                                      selectedEntries: selectedEntries,
                                      remarks:
                                          'Generated from Multiple Challans Section',
                                    );

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
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                              child: Text(
                                'Generate Individual Challans',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Combined Challan Option
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.merge_type,
                                color: Colors.green[600],
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Combined Challan',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Merge all selected payments into one comprehensive challan',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.green[700],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Get.back(); // Close type selection dialog
                                Get.back(); // Close main dialog

                                final success =
                                    await CombinedChallanService.generateCombinedChallan(
                                      studentId: studentId,
                                      month: selectedMonth,
                                      selectedEntries: selectedEntries,
                                      createdBy:
                                          'Admin', // TODO: Get from current user
                                    );

                                if (success) {
                                  Get.snackbar(
                                    'Success',
                                    'Combined challan generated successfully!',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to generate combined challan.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                              child: Text(
                                'Generate Combined Challan',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
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

  void _showPrintChallanDialogForMultiple(
    Map<String, dynamic> challan,
    BuildContext context,
  ) {
    final dueDateController = TextEditingController();
    final validationDateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    DateTime? selectedDueDate;
    DateTime? selectedValidationDate;

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
                width: MediaQuery.of(context).size.width > 600 ? 450.w : 400.w,
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
                                Icons.print,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Text(
                                'Print Challan',
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

                        // Challan Info
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
                                    'Challan ID',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    challan['id'].toString(),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Amount',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'PKR ${challan['total_amount'].toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Due Date Field
                        TextFormField(
                          controller: dueDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Challan Due Date',
                            hintText: 'Select due date',
                            prefixIcon: Icon(
                              Icons.calendar_today,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.date_range,
                                color: AppColors.primary,
                              ),
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (pickedDate != null) {
                                  selectedDueDate = pickedDate;
                                  dueDateController.text = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(pickedDate);
                                }
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Due date is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Validation Date Field
                        TextFormField(
                          controller: validationDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Validation Date',
                            hintText: 'Select validation date',
                            prefixIcon: Icon(
                              Icons.event_available,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.date_range,
                                color: AppColors.primary,
                              ),
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      selectedDueDate ?? DateTime.now(),
                                  firstDate: selectedDueDate ?? DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (pickedDate != null) {
                                  selectedValidationDate = pickedDate;
                                  validationDateController.text = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(pickedDate);
                                }
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Validation date is required';
                            }
                            if (selectedDueDate != null &&
                                selectedValidationDate != null) {
                              if (selectedValidationDate!.isBefore(
                                selectedDueDate!,
                              )) {
                                return 'Validation date must be after due date';
                              }
                            }
                            return null;
                          },
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
                                    try {
                                      // Print challan with the selected dates
                                      await ChallanPrintService.printChallan(
                                        challan['id'].toString(),
                                        context,
                                        dueDate: selectedDueDate,
                                        validationDate: selectedValidationDate,
                                      );
                                      Get.back(); // Close dialog
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error',
                                        'Failed to print challan: $e',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red[100],
                                        colorText: Colors.red[800],
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
                                  'Print Challan',
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
}
