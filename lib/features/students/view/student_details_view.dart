import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/student_model.dart';

class StudentDetailsView extends StatefulWidget {
  final StudentModel student;

  const StudentDetailsView({super.key, required this.student});

  @override
  State<StudentDetailsView> createState() => _StudentDetailsViewState();
}

class _StudentDetailsViewState extends State<StudentDetailsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _closeDialog(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping dialog
                    child: Container(
                      width: 800.w,
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAvatar(),
                                  SizedBox(height: 12.h),
                                  _buildPersonalInfoSection(),
                                  SizedBox(height: 12.h),
                                  _buildAcademicInfoSection(),
                                  SizedBox(height: 12.h),
                                  _buildContactInfoSection(),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Student Details',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _closeDialog,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(Icons.close, color: Colors.grey[600], size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              widget.student.studentName.isNotEmpty
                  ? widget.student.studentName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            widget.student.studentName,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.student.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              widget.student.status,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: _getStatusColor(widget.student.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildInfoSection(
      emoji: '👤',
      title: 'Personal Information',
      items: [
        _InfoItem(label: 'Full Name', value: widget.student.studentName),
        _InfoItem(label: 'Roll No', value: widget.student.rollNo),
        _InfoItem(label: 'GR No', value: widget.student.grNo),
        _InfoItem(label: 'Gender', value: widget.student.gender),
        _InfoItem(
          label: 'Date of Birth',
          value: _formatDate(widget.student.dobFigures),
        ),
        _InfoItem(label: 'Religion', value: widget.student.religion),
        _InfoItem(label: 'Caste', value: widget.student.caste),
        _InfoItem(label: 'Place of Birth', value: widget.student.placeOfBirth),
      ],
    );
  }

  Widget _buildAcademicInfoSection() {
    return _buildInfoSection(
      emoji: '🎓',
      title: 'Academic Details',
      items: [
        _InfoItem(
          label: 'Class & Section',
          value: '${widget.student.className} - ${widget.student.section}',
        ),
        _InfoItem(
          label: 'Admission Date',
          value: _formatDate(widget.student.admissionDate),
        ),
        _InfoItem(
          label: 'Admission Fees',
          value: 'Rs. ${widget.student.admissionFees.toStringAsFixed(0)}',
        ),
        _InfoItem(
          label: 'Monthly Fees',
          value: 'Rs. ${widget.student.monthlyFees.toStringAsFixed(0)}',
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildInfoSection(
      emoji: '📞',
      title: 'Contact Information',
      items: [
        _InfoItem(label: 'Father Name', value: widget.student.fatherName),
        _InfoItem(label: 'Father Contact', value: widget.student.fatherContact),
        _InfoItem(label: 'Mother Contact', value: widget.student.motherContact),
        _InfoItem(label: 'Address', value: widget.student.address),
      ],
    );
  }

  Widget _buildInfoSection({
    required String emoji,
    required String title,
    required List<_InfoItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 8.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
              return Wrap(
                spacing: 16.w,
                runSpacing: 8.h,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: crossAxisCount == 2
                            ? (constraints.maxWidth - 16.w) / 2
                            : constraints.maxWidth,
                        child: _buildInfoGridItem(item),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGridItem(_InfoItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${item.label}:',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: Text(
              item.value.isNotEmpty ? item.value : 'Not provided',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not provided';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _closeDialog() {
    _animationController.reverse().then((_) {
      Get.back();
    });
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});
}
