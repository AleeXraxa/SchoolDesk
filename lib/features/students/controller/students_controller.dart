import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/student_service.dart';
import '../../../data/models/student_model.dart';
import '../../../widgets/result_dialog.dart';
import '../../classes/controller/classes_controller.dart';
import '../controller/new_admission_controller.dart';
import '../view/new_admission_view.dart';
import '../view/student_details_view.dart';

class StudentsController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<StudentModel> allStudents = <StudentModel>[].obs;
  RxList<StudentModel> filteredStudents = <StudentModel>[].obs;
  RxString sortColumn = ''.obs;
  RxBool sortAscending = true.obs;
  RxString searchQuery = ''.obs;
  RxMap<String, String> filters = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      isLoading.value = true;
      print('StudentsController: Fetching students from database');

      final result = await StudentService.getAllStudents();
      allStudents.assignAll(result);
      filteredStudents.assignAll(result);

      print('StudentsController: Loaded ${result.length} students');
    } catch (e, stackTrace) {
      print('StudentsController: Error fetching students: $e');
      print('StudentsController: Stack trace: $stackTrace');

      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Load Students',
        message: 'Failed to load students from database. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStudents() async {
    await fetchStudents();
  }

  Future<void> refreshStudents() async {
    await loadStudents();
  }

  Future<void> bulkInsertSampleStudents() async {
    try {
      print('StudentsController: Starting bulk insert of sample students');

      // Get existing classes to assign students to
      final classesController = Get.find<ClassesController>();
      await classesController.fetchClasses();
      final availableClasses = classesController.classes;

      if (availableClasses.isEmpty) {
        ResultDialog.showError(
          Get.context!,
          title: 'No Classes Available',
          message:
              'Please add some classes first before inserting sample students.',
        );
        return;
      }

      // Generate 100 sample students
      final sampleStudents = <StudentModel>[];
      final firstNames = [
        'Ahmed',
        'Muhammad',
        'Ali',
        'Hassan',
        'Hussain',
        'Fatima',
        'Ayesha',
        'Maryam',
        'Zainab',
        'Khadija',
        'Omar',
        'Usman',
        'Abu Bakr',
        'Umar',
        'Bilal',
        'Saad',
        'Talha',
        'Zubair',
        'Abdullah',
        'Ibrahim',
        'Sara',
        'Huda',
        'Nadia',
        'Laila',
        'Rania',
        'Sofia',
        'Zara',
        'Amina',
        'Noor',
        'Hana',
        'Yusuf',
        'Hamza',
        'Haris',
        'Rayyan',
        'Arham',
        'Aryan',
        'Zayan',
        'Ayaan',
        'Rayan',
        'Shaheer',
        'Maira',
        'Sana',
        'Hira',
        'Anam',
        'Sadia',
        'Bushra',
        'Asma',
        'Naila',
        'Farah',
        'Saima',
      ];

      final lastNames = [
        'Khan',
        'Ahmed',
        'Ali',
        'Hussain',
        'Shah',
        'Malik',
        'Butt',
        'Javed',
        'Iqbal',
        'Raza',
        'Akhtar',
        'Siddiqui',
        'Qureshi',
        'Sheikh',
        'Mirza',
        'Chaudhry',
        'Syed',
        'Bukhari',
        'Farooqi',
        'Zaidi',
        'Patel',
        'Shaikh',
        'Memon',
        'Rajput',
        'Baloch',
        'Punjabi',
        'Sindhi',
        'Pathan',
        'Arain',
        'Gujjar',
      ];

      final cities = [
        'Karachi',
        'Lahore',
        'Islamabad',
        'Rawalpindi',
        'Faisalabad',
        'Multan',
        'Peshawar',
        'Quetta',
        'Sialkot',
        'Gujranwala',
      ];

      final castes = [
        'Sunni',
        'Shia',
        'Wahabi',
        'Deobandi',
        'Barelvi',
        'Ahle Hadith',
        'Ismaili',
        'Christian',
        'Hindu',
        'Sikh',
      ];

      final religions = ['Islam', 'Christianity', 'Hinduism', 'Sikhism'];

      final placesOfBirth = cities;

      for (int i = 1; i <= 100; i++) {
        final firstName = firstNames[(i - 1) % firstNames.length];
        final lastName = lastNames[(i - 1) % lastNames.length];
        final fullName = '$firstName $lastName';

        // Generate date of birth (between 5-18 years old)
        final now = DateTime.now();
        final birthYear = now.year - (5 + (i % 14)); // 5 to 18 years old
        final birthMonth = 1 + (i % 12);
        final birthDay = 1 + (i % 28);
        final dob = DateTime(birthYear, birthMonth, birthDay);

        // Generate admission date (within last 2 years)
        final admissionDaysAgo = i % 730; // Within 2 years
        final admissionDate = now.subtract(Duration(days: admissionDaysAgo));

        // Assign to a class (distribute evenly)
        final classIndex = (i - 1) % availableClasses.length;
        final assignedClass = availableClasses[classIndex];

        // Generate contact info
        final phoneBase = 3000000000 + i;
        final fatherPhone = '+92${phoneBase.toString().substring(1)}';
        final motherPhone =
            '+92${(phoneBase + 1000000000).toString().substring(1)}';

        // Generate email
        final email =
            '${firstName.toLowerCase()}.${lastName.toLowerCase()}$i@example.com';

        // Generate address
        final city = cities[i % cities.length];
        final address =
            '${i * 10} ${['Street', 'Road', 'Avenue', 'Lane'][i % 4]}, $city, Pakistan';

        final student = StudentModel(
          rollNo: 'STD${i.toString().padLeft(4, '0')}',
          grNo: 'GR${i.toString().padLeft(4, '0')}',
          studentName: fullName,
          fatherName: '${lastNames[(i + 5) % lastNames.length]} $lastName',
          caste: castes[i % castes.length],
          placeOfBirth: placesOfBirth[i % placesOfBirth.length],
          dobFigures: dob,
          dobWords: _dateToWords(dob),
          gender: i % 2 == 0 ? 'Male' : 'Female',
          religion: religions[i % religions.length],
          fatherContact: fatherPhone,
          motherContact: motherPhone,
          address: address,
          admissionDate: admissionDate,
          classId: assignedClass.id,
          className: assignedClass.className,
          section: assignedClass.section,
          admissionFees: 5000.0 + (i % 5) * 1000.0, // 5000 to 9000
          monthlyFees: 2000.0 + (i % 3) * 500.0, // 2000 to 3000
          status: i % 10 == 0 ? 'Inactive' : 'Active', // 10% inactive
        );

        sampleStudents.add(student);
      }

      // Bulk insert all students
      await StudentService.bulkInsertStudents(sampleStudents);

      // Refresh the student list
      await loadStudents();

      // Update classes with new student counts
      await classesController.fetchClasses();

      ResultDialog.showSuccess(
        Get.context!,
        title: 'Sample Students Added',
        message: 'Successfully added 100 sample students to the database.',
      );

      print(
        'StudentsController: Successfully bulk inserted 100 sample students',
      );
    } catch (e, stackTrace) {
      print('StudentsController: Error bulk inserting sample students: $e');
      print('StudentsController: Stack trace: $stackTrace');

      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Add Sample Students',
        message: 'Failed to add sample students. Please try again.',
      );
    }
  }

  String _dateToWords(DateTime date) {
    final months = [
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

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$day $month $year';
  }

  void addNewStudent() {
    // TODO: Implement add student functionality
    ResultDialog.showSuccess(
      Get.context!,
      title: 'Coming Soon',
      message: 'New student admission feature will be available soon!',
    );
  }

  Future<void> viewStudent(String rollNo) async {
    try {
      // Find the student by roll number
      final student = allStudents.firstWhere(
        (s) => s.rollNo == rollNo,
        orElse: () => throw Exception('Student not found'),
      );

      // Show the dialog
      Get.dialog(
        StudentDetailsView(student: student),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load student details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> editStudent(String rollNo) async {
    try {
      // Find the student by roll number
      final student = allStudents.firstWhere(
        (s) => s.rollNo == rollNo,
        orElse: () => throw Exception('Student not found'),
      );

      // Get or create the admission controller
      if (!Get.isRegistered<NewAdmissionController>()) {
        Get.put(NewAdmissionController(), permanent: true);
      }
      final admissionController = Get.find<NewAdmissionController>();

      // Load student data into the form
      admissionController.loadStudentForEdit(student);

      // Open the admission dialog in edit mode
      Get.dialog(const NewAdmissionView(), barrierDismissible: false);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load student for editing: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      print('StudentsController: Deleting student with ID: $id');

      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmationDialog(id);
      if (!confirmed) return;

      // Delete from database
      await StudentService.deleteStudent(id);

      // Refresh the students list
      await loadStudents();

      // Refresh classes to update total students count
      final classesController = Get.find<ClassesController>();
      await classesController.fetchClasses();

      // Show success dialog
      ResultDialog.showSuccess(
        Get.context!,
        title: 'Student Deleted Successfully',
        message: 'The student has been removed from the system.',
      );

      print('StudentsController: Student deleted successfully');
    } catch (e, stackTrace) {
      print('StudentsController: Error deleting student: $e');
      print('StudentsController: Stack trace: $stackTrace');

      // Show error dialog
      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Delete Student',
        message: 'Failed to delete student. Please try again later.',
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(int studentId) async {
    final result = await Get.dialog<bool>(
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
                width: 320.w,
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
                    // Warning icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 30.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Title
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 50.0, end: 0.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: Opacity(
                            opacity: (50 - offset) / 50,
                            child: Text(
                              'Confirm Deletion',
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Message
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            'Are you sure you want to delete this student?\n\nThis action cannot be undone.',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Buttons
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Row(
                            children: [
                              // Cancel button
                              Expanded(
                                child: SizedBox(
                                  height: 45.h,
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(result: false),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),

                              // Delete button
                              Expanded(
                                child: SizedBox(
                                  height: 45.h,
                                  child: ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

    return result ?? false;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void updateFilter(String column, String value) {
    if (value.isEmpty) {
      filters.remove(column);
    } else {
      filters[column] = value;
    }
    applyFilters();
  }

  void applyFilters() {
    var filtered = allStudents.where((student) {
      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesSearch =
            student.studentName.toLowerCase().contains(query) ||
            student.rollNo.toLowerCase().contains(query) ||
            student.fatherName.toLowerCase().contains(query) ||
            student.className.toLowerCase().contains(query) ||
            student.section.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Column filters
      for (final entry in filters.entries) {
        final column = entry.key;
        final filterValue = entry.value.toLowerCase();
        final studentValue = column == 'className'
            ? student.className.toLowerCase()
            : student.section.toLowerCase();
        if (!studentValue.contains(filterValue)) {
          return false;
        }
      }

      return true;
    }).toList();

    filteredStudents.value = filtered;
  }

  List<String> getUniqueValues(String column) {
    if (column == 'className') {
      return allStudents
          .map((student) => student.className)
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } else if (column == 'section') {
      return allStudents
          .map((student) => student.section)
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }

  void clearFilters() {
    filters.clear();
    searchQuery.value = '';
    filteredStudents.value = List.from(allStudents);
  }

  void sortByColumn(String column) {
    if (sortColumn.value == column) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
    // No applyFilters call needed since sorting is handled in the view
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    // Try to parse as numbers first
    final numA = num.tryParse(a.toString());
    final numB = num.tryParse(b.toString());

    if (numA != null && numB != null) {
      return numA.compareTo(numB);
    }

    // Otherwise compare as strings
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }
}
