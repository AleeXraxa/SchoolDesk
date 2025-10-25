import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/misc_fees_controller.dart';
import '../../../features/classes/model/class_model.dart';
import '../../../features/classes/service/class_service.dart';
import '../../../data/models/student_model.dart';
import '../../../data/database_service.dart';

enum GenerationMode { classWise, individual }

class MiscGenerateFeesDialog extends StatefulWidget {
  const MiscGenerateFeesDialog({super.key});

  @override
  State<MiscGenerateFeesDialog> createState() => _MiscGenerateFeesDialogState();
}

class _MiscGenerateFeesDialogState extends State<MiscGenerateFeesDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  GenerationMode selectedMode = GenerationMode.classWise;

  // Class-wise generation variables
  ClassModel? selectedClass;
  String? selectedMonth;
  String? selectedMiscFeeType;
  double? classFeeAmount;
  String? classDescription;
  List<StudentModel> classStudents = [];
  bool isLoadingStudents = false;

  // Individual generation variables
  String rollNumber = '';
  StudentModel? selectedStudent;
  bool isSearchingStudent = false;
  double? individualFeeAmount;
  String? individualDescription;

  // Text controllers for persistent input
  late TextEditingController rollNumberController;
  late TextEditingController classFeeAmountController;
  late TextEditingController classDescriptionController;
  late TextEditingController individualFeeAmountController;
  late TextEditingController individualDescriptionController;

  // Common variables
  final List<String> miscFeeTypes = [
    'Library Fine',
    'Sports Fee',
    'Lab Maintenance',
    'Transportation',
    'Stationery',
    'Activity Fee',
    'Late Fee',
    'Other',
  ];

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<ClassModel> classes = [];
  bool isLoadingClasses = true;

  @override
  void initState() {
    super.initState();

    // Initialize text controllers
    rollNumberController = TextEditingController();
    classFeeAmountController = TextEditingController();
    classDescriptionController = TextEditingController();
    individualFeeAmountController = TextEditingController();
    individualDescriptionController = TextEditingController();

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
    _loadClasses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    rollNumberController.dispose();
    classFeeAmountController.dispose();
    classDescriptionController.dispose();
    individualFeeAmountController.dispose();
    individualDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    try {
      setState(() => isLoadingClasses = true);
      final loadedClasses = await ClassService.getAllClasses();
      setState(() {
        classes = loadedClasses;
        isLoadingClasses = false;
      });
    } catch (e) {
      print('Error loading classes: $e');
      setState(() => isLoadingClasses = false);
    }
  }

  Future<void> _loadClassStudents() async {
    if (selectedClass == null) return;

    try {
      setState(() => isLoadingStudents = true);
      final db = await DatabaseService.database;
      final result = await db.query(
        'students',
        where: 'class_id = ? AND status = ?',
        whereArgs: [selectedClass!.id, 'Active'],
      );

      final students = result
          .map((json) => StudentModel.fromJson(json))
          .toList();
      setState(() {
        classStudents = students;
        isLoadingStudents = false;
      });
    } catch (e) {
      print('Error loading class students: $e');
      setState(() => isLoadingStudents = false);
    }
  }

  Future<void> _searchStudentByRollNumber(String rollNo) async {
    if (rollNo.trim().isEmpty) {
      setState(() => selectedStudent = null);
      return;
    }

    try {
      setState(() => isSearchingStudent = true);
      final db = await DatabaseService.database;

      // Use case-insensitive search for roll number
      final result = await db.rawQuery(
        '''
        SELECT * FROM students
        WHERE LOWER(TRIM(roll_no)) = LOWER(TRIM(?)) AND status = ?
        ''',
        [rollNo.trim(), 'Active'],
      );

      print(
        'Searching for roll number: "${rollNo.trim()}", found ${result.length} results',
      );

      if (result.isNotEmpty) {
        setState(() => selectedStudent = StudentModel.fromJson(result.first));
        print(
          'Student found: ${selectedStudent!.studentName} (${selectedStudent!.rollNo})',
        );
      } else {
        setState(() => selectedStudent = null);
        print('No student found with roll number: "${rollNo.trim()}"');
      }
    } catch (e) {
      print('Error searching student: $e');
      setState(() => selectedStudent = null);
    } finally {
      setState(() => isSearchingStudent = false);
    }
  }

  bool get _isClassWiseValid {
    return selectedClass != null &&
        selectedMonth != null &&
        selectedMiscFeeType != null &&
        classFeeAmount != null &&
        classFeeAmount! > 0 &&
        classStudents.isNotEmpty;
  }

  bool get _isIndividualValid {
    return selectedStudent != null &&
        selectedMonth != null &&
        selectedMiscFeeType != null &&
        individualFeeAmount != null &&
        individualFeeAmount! > 0;
  }

  double get _totalClassAmount => (classFeeAmount ?? 0) * classStudents.length;

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
                      width: MediaQuery.of(context).size.width > 600
                          ? 600.w
                          : 500.w,
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
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
                              padding: EdgeInsets.all(24.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildModeSelector(),
                                  SizedBox(height: 24.h),
                                  _buildFormSection(),
                                  SizedBox(height: 24.h),
                                  _buildSummarySection(),
                                  SizedBox(height: 24.h),
                                  _buildActionButtons(),
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
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
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
              Icons.add_circle,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Generate Misc Fees',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
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

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generation Mode',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildModeOption(
                mode: GenerationMode.classWise,
                title: 'Class-wise',
                subtitle: 'Generate fees for entire class',
                icon: Icons.group,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildModeOption(
                mode: GenerationMode.individual,
                title: 'Individual',
                subtitle: 'Generate fee for single student',
                icon: Icons.person,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeOption({
    required GenerationMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedMode == mode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => selectedMode = mode);
            // Reset form when switching modes
            if (mode == GenerationMode.classWise) {
              selectedStudent = null;
              rollNumberController.clear();
              individualFeeAmountController.clear();
              individualDescriptionController.clear();
              rollNumber = '';
              individualFeeAmount = null;
              individualDescription = null;
            } else {
              selectedClass = null;
              classStudents = [];
              classFeeAmountController.clear();
              classDescriptionController.clear();
              classFeeAmount = null;
              classDescription = null;
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
              color: isSelected
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.white,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                  size: 24.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: selectedMode == GenerationMode.classWise
          ? _buildClassWiseForm()
          : _buildIndividualForm(),
    );
  }

  Widget _buildClassWiseForm() {
    return Column(
      key: const ValueKey('classWise'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class-wise Fee Generation',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),

        // Class Selection
        _buildDropdownField(
          label: 'Select Class',
          hint: 'Choose a class',
          value: selectedClass?.displayName,
          items: classes.map((c) => c.displayName).toList(),
          onChanged: (value) {
            final classItem = classes.firstWhere((c) => c.displayName == value);
            setState(() {
              selectedClass = classItem;
              classStudents = [];
            });
            _loadClassStudents();
          },
          icon: Icons.class_,
        ),

        SizedBox(height: 16.h),

        // Month Selection
        _buildDropdownField(
          label: 'Select Month',
          hint: 'Choose month',
          value: selectedMonth,
          items: months,
          onChanged: (value) => setState(() => selectedMonth = value),
          icon: Icons.calendar_month,
        ),

        SizedBox(height: 16.h),

        // Fee Type Selection
        _buildDropdownField(
          label: 'Misc Fee Type',
          hint: 'Select fee type',
          value: selectedMiscFeeType,
          items: miscFeeTypes,
          onChanged: (value) => setState(() => selectedMiscFeeType = value),
          icon: Icons.category,
        ),

        SizedBox(height: 16.h),

        // Fee Amount
        _buildTextField(
          label: 'Fee Amount (PKR)',
          hint: 'Enter amount per student',
          controller: classFeeAmountController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final amount = double.tryParse(value);
            setState(() => classFeeAmount = amount);
          },
          icon: Icons.attach_money,
        ),

        SizedBox(height: 16.h),

        // Description
        _buildTextField(
          label: 'Description (Optional)',
          hint: 'Add remarks or description',
          controller: classDescriptionController,
          maxLines: 3,
          onChanged: (value) => setState(() => classDescription = value),
          icon: Icons.description,
        ),
      ],
    );
  }

  Widget _buildIndividualForm() {
    return Column(
      key: const ValueKey('individual'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Individual Student Fee Generation',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),

        // Roll Number Input
        _buildTextField(
          label: 'Roll Number',
          hint: 'Enter student roll number',
          controller: rollNumberController,
          onChanged: (value) {
            setState(() => rollNumber = value);
            if (value.trim().length >= 1) {
              // Changed from >= 2 to >= 1 for immediate search
              _searchStudentByRollNumber(value);
            } else {
              setState(() => selectedStudent = null);
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
          ],
          icon: Icons.badge,
        ),

        // Student Details Display
        if (isSearchingStudent)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Searching student...',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else if (selectedStudent != null)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedStudent!.studentName,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                      Text(
                        '${selectedStudent!.className} ${selectedStudent!.section}',
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
          )
        else if (rollNumber.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red[600], size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Student not found',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 16.h),

        // Month Selection
        _buildDropdownField(
          label: 'Select Month',
          hint: 'Choose month',
          value: selectedMonth,
          items: months,
          onChanged: (value) => setState(() => selectedMonth = value),
          icon: Icons.calendar_month,
        ),

        SizedBox(height: 16.h),

        // Fee Type Selection
        _buildDropdownField(
          label: 'Misc Fee Type',
          hint: 'Select fee type',
          value: selectedMiscFeeType,
          items: miscFeeTypes,
          onChanged: (value) => setState(() => selectedMiscFeeType = value),
          icon: Icons.category,
        ),

        SizedBox(height: 16.h),

        // Fee Amount
        _buildTextField(
          label: 'Fee Amount (PKR)',
          hint: 'Enter fee amount',
          controller: individualFeeAmountController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final amount = double.tryParse(value);
            setState(() => individualFeeAmount = amount);
          },
          icon: Icons.attach_money,
        ),

        SizedBox(height: 16.h),

        // Description
        _buildTextField(
          label: 'Description (Optional)',
          hint: 'Add remarks or description',
          controller: individualDescriptionController,
          maxLines: 3,
          onChanged: (value) => setState(() => individualDescription = value),
          icon: Icons.description,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: GoogleFonts.poppins(fontSize: 14.sp)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.poppins(fontSize: 14.sp),
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    if (selectedMode == GenerationMode.classWise) {
      return _buildClassWiseSummary();
    } else {
      return _buildIndividualSummary();
    }
  }

  Widget _buildClassWiseSummary() {
    return Container(
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
              Icon(Icons.analytics, color: Colors.blue[600], size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Summary',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (isLoadingStudents)
            Center(child: CircularProgressIndicator())
          else ...[
            _buildSummaryRow(
              'Class Selected:',
              selectedClass?.displayName ?? 'None',
            ),
            _buildSummaryRow('Students Count:', '${classStudents.length}'),
            _buildSummaryRow(
              'Fee per Student:',
              'PKR ${classFeeAmount?.toStringAsFixed(0) ?? '0'}',
            ),
            Divider(height: 16.h),
            _buildSummaryRow(
              'Total Amount:',
              'PKR ${_totalClassAmount.toStringAsFixed(0)}',
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndividualSummary() {
    return Container(
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
              Icon(Icons.person, color: Colors.green[600], size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Summary',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (selectedStudent != null) ...[
            _buildSummaryRow('Student:', selectedStudent!.studentName),
            _buildSummaryRow('Roll No:', selectedStudent!.rollNo),
            _buildSummaryRow(
              'Class:',
              '${selectedStudent!.className} ${selectedStudent!.section}',
            ),
            _buildSummaryRow(
              'Fee Amount:',
              'PKR ${individualFeeAmount?.toStringAsFixed(0) ?? '0'}',
            ),
          ] else
            Text(
              'Please select a valid student',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isBold ? Colors.black87 : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isValid = selectedMode == GenerationMode.classWise
        ? _isClassWiseValid
        : _isIndividualValid;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _closeDialog,
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
            onPressed: isValid ? _generateFees : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? AppColors.primary : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: isValid ? 2 : 0,
            ),
            child: Text(
              selectedMode == GenerationMode.classWise
                  ? 'Generate Fees'
                  : 'Generate Fee',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generateFees() async {
    try {
      final controller = Get.find<MiscFeesController>();
      String message = '';
      String successTitle = '';

      if (selectedMode == GenerationMode.classWise) {
        // Generate fees for entire class
        message = await controller.generateMiscFeesForClass(
          selectedClass!.id!,
          selectedMonth!,
          selectedMiscFeeType!,
          classFeeAmount!,
          description: classDescription,
        );
        successTitle = 'Misc Fees Generated Successfully';
      } else {
        // Generate fee for individual student
        message = await controller.generateMiscFeeForStudent(
          selectedStudent!.id!,
          selectedMonth!,
          selectedMiscFeeType!,
          individualFeeAmount!,
          description: individualDescription,
        );
        successTitle = 'Misc Fee Generated Successfully';
      }

      // Show success dialog (don't close generation dialog yet)
      _showSuccessDialog(successTitle, message);

      // Refresh data in background
      await controller.loadMiscFees();
    } catch (e) {
      // Show modern info dialog for duplicate fees instead of error dialog
      if (e.toString().contains('already exist')) {
        _showDuplicateFeesDialog(
          'Misc Fees for this ${selectedMode == GenerationMode.classWise ? 'class' : 'student'} and month already exist.',
        );
      } else {
        // Show error dialog for other errors
        _showErrorDialog(
          'Failed to generate fees: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  void _showSuccessDialog(String title, String message) {
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
                    // Success Icon with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green[400]!,
                                  Colors.green[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Title with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, (1 - opacity) * 20),
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Message with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            message,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // OK Button with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 4,
                                shadowColor: Colors.green.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Continue',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    ).then((_) {
      // Close the generation dialog after success dialog is dismissed
      _closeDialog();
    });
  }

  void _showDuplicateFeesDialog(String message) {
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
                    // Info Icon with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.info,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Title with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, (1 - opacity) * 20),
                            child: Text(
                              'Fees Already Exist',
                              style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Message with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            message,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.blue[600],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // OK Button with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 4,
                                shadowColor: Colors.blue.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'OK',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  void _showErrorDialog(String errorMessage) {
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
                    // Error Icon with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red[400]!, Colors.red[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Title with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, (1 - opacity) * 20),
                            child: Text(
                              'Generation Failed',
                              style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Error Message with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            errorMessage,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.red[600],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // OK Button with Animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 4,
                                shadowColor: Colors.red.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'OK',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  void _closeDialog() {
    _animationController.reverse().then((_) {
      Get.back();
    });
  }
}
