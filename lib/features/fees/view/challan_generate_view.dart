import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallanGenerateView extends StatelessWidget {
  const ChallanGenerateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Challan',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),

            // Manual/Combined Challan Generation Section
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
                          Icons.add_circle,
                          color: Colors.green[600],
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manual / Combined Challan Generation',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Create custom challans by selecting specific paid fees for students',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Instructions
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8.r),
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
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'How to Generate Manual Challan',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _buildInstructionStep(
                          '1',
                          'Click the "Generate Challan" button in the header',
                        ),
                        SizedBox(height: 8.h),
                        _buildInstructionStep(
                          '2',
                          'Search and select a student by roll number or name',
                        ),
                        SizedBox(height: 8.h),
                        _buildInstructionStep(
                          '3',
                          'Review and select paid fees to include in the challan',
                        ),
                        SizedBox(height: 8.h),
                        _buildInstructionStep(
                          '4',
                          'Preview and generate the combined challan',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Placeholder for manual generation interface
                  Container(
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
                            Icons.add_circle_outline,
                            size: 48.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Use the "Generate Challan" button above',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'to create manual challans',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
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

  Widget _buildInstructionStep(String step, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
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
              fontSize: 12.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
