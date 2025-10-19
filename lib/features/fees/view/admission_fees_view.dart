import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/admission_fees_controller.dart';
import 'pending_fees_view.dart';
import 'paid_fees_view.dart';

class AdmissionFeesView extends StatelessWidget {
  const AdmissionFeesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller if not already present
    final admissionController = Get.put(
      AdmissionFeesController(),
      permanent: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildSearchBar(admissionController),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Pending Fees Section
                  Container(
                    margin: EdgeInsets.all(16.w),
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height *
                          0.3, // Minimum height
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.6, // Maximum height
                    ),
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
                    child: const PendingFeesView(),
                  ),
                  SizedBox(height: 16.h), // Spacing between tables
                  // Paid Fees Section
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ).copyWith(bottom: 16.w),
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height *
                          0.3, // Minimum height
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.6, // Maximum height
                    ),
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
                    child: const PaidFeesView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AdmissionFeesController admissionController) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller:
                    TextEditingController(
                        text: admissionController.searchQuery.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: admissionController.searchQuery.value.length,
                      ),
                onChanged: admissionController.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
