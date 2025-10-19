import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/result_dialog.dart';
import '../../classes/service/class_service.dart';
import '../../classes/model/class_model.dart';
import '../../classes/controller/classes_controller.dart';
import '../service/student_service.dart';
import '../controller/students_controller.dart';
import '../../../data/models/student_model.dart';

class NewAdmissionController extends GetxController {
  // Step management
  RxInt currentStep = 0.obs;
  final int totalSteps = 4;

  // Form keys for validation
  final personalDetailsFormKey = GlobalKey<FormState>();
  final classAssignmentFormKey = GlobalKey<FormState>();
  final feesFormKey = GlobalKey<FormState>();

  // Step 1: Personal Details
  final rollNoController = TextEditingController();
  final grNoController = TextEditingController();
  final studentNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final casteController = TextEditingController();
  final placeOfBirthController = TextEditingController();
  final addressController = TextEditingController();
  final fathersContactController = TextEditingController();
  final mothersContactController = TextEditingController();

  Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  RxString dateOfBirthInWords = ''.obs;
  RxString selectedGender = 'Male'.obs;
  RxString selectedReligion = 'Muslim'.obs;

  // Step 2: Class Assignment
  RxString selectedClass = ''.obs;
  RxString selectedSection = ''.obs;

  // Dynamic class data
  RxList<ClassModel> availableClasses = <ClassModel>[].obs;
  RxList<String> classOptions = <String>[].obs;
  RxList<String> sectionOptions = <String>[].obs;
  RxBool isLoadingClasses = true.obs;

  // Step 3: Fees Amount
  final admissionFeesController = TextEditingController();
  final monthlyFeesController = TextEditingController();

  // Dropdown options
  final genderOptions = ['Male', 'Female', 'Other'];
  final religionOptions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Buddhist',
    'Jain',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    // Set default values
    dateOfBirth.value = DateTime.now().subtract(
      const Duration(days: 365 * 6),
    ); // 6 years ago
    _updateDateOfBirthInWords();

    // Load classes for Step 2
    loadClasses();
  }

  @override
  void onClose() {
    // Dispose controllers
    rollNoController.dispose();
    grNoController.dispose();
    studentNameController.dispose();
    fatherNameController.dispose();
    casteController.dispose();
    placeOfBirthController.dispose();
    addressController.dispose();
    fathersContactController.dispose();
    mothersContactController.dispose();
    admissionFeesController.dispose();
    monthlyFeesController.dispose();
    super.onClose();
  }

  void nextStep() {
    if (_validateCurrentStep()) {
      if (currentStep.value < totalSteps - 1) {
        currentStep.value++;
      }
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool _validateCurrentStep() {
    print('NewAdmissionController: Validating step ${currentStep.value}');
    switch (currentStep.value) {
      case 0:
        final result = personalDetailsFormKey.currentState?.validate() ?? false;
        print('NewAdmissionController: Step 0 validation result: $result');
        return result;
      case 1:
        final result = classAssignmentFormKey.currentState?.validate() ?? false;
        print('NewAdmissionController: Step 1 validation result: $result');
        return result;
      case 2:
        final result = feesFormKey.currentState?.validate() ?? false;
        print('NewAdmissionController: Step 2 validation result: $result');
        return result;
      default:
        return true;
    }
  }

  void setDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
    _updateDateOfBirthInWords();
  }

  void _updateDateOfBirthInWords() {
    if (dateOfBirth.value != null) {
      dateOfBirthInWords.value = DateFormat(
        'dd MMMM yyyy',
      ).format(dateOfBirth.value!);
    }
  }

  Future<void> submitAdmission() async {
    try {
      print('NewAdmissionController: Starting admission submission');

      // Check if all forms are available
      if (personalDetailsFormKey.currentState == null ||
          classAssignmentFormKey.currentState == null ||
          feesFormKey.currentState == null) {
        print('NewAdmissionController: One or more forms not available');
        print(
          'personalDetailsFormKey.currentState: ${personalDetailsFormKey.currentState}',
        );
        print(
          'classAssignmentFormKey.currentState: ${classAssignmentFormKey.currentState}',
        );
        print('feesFormKey.currentState: ${feesFormKey.currentState}');
        Get.snackbar(
          'Error',
          'Form not ready. Please reopen admission form.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate all forms
      bool personalValid =
          personalDetailsFormKey.currentState?.validate() ?? false;
      bool classValid =
          classAssignmentFormKey.currentState?.validate() ?? false;
      bool feesValid = feesFormKey.currentState?.validate() ?? false;

      if (!personalValid) {
        print('NewAdmissionController: Personal details validation failed');
        Get.snackbar(
          'Validation Error',
          'Please complete all personal details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        goToStep(0);
        return;
      }

      if (!classValid) {
        print('NewAdmissionController: Class assignment validation failed');
        Get.snackbar(
          'Validation Error',
          'Please select a class and section',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        goToStep(1);
        return;
      }

      if (!feesValid) {
        print('NewAdmissionController: Fees validation failed');
        Get.snackbar(
          'Validation Error',
          'Please enter valid fee amounts',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        goToStep(2);
        return;
      }

      print('NewAdmissionController: All validations passed');

      // Find the class ID for the selected class and section
      final selectedClassObj = availableClasses.firstWhere(
        (classItem) =>
            classItem.className == selectedClass.value &&
            classItem.section == selectedSection.value,
        orElse: () => throw Exception('Selected class not found'),
      );

      // Create student model
      final student = StudentModel(
        rollNo: rollNoController.text.trim(),
        grNo: grNoController.text.trim(),
        studentName: studentNameController.text.trim(),
        fatherName: fatherNameController.text.trim(),
        caste: casteController.text.trim(),
        placeOfBirth: placeOfBirthController.text.trim(),
        dobFigures:
            dateOfBirth.value ??
            DateTime.now().subtract(const Duration(days: 365 * 6)),
        dobWords: dateOfBirthInWords.value,
        gender: selectedGender.value,
        religion: selectedReligion.value,
        fatherContact: fathersContactController.text.trim(),
        motherContact: mothersContactController.text.trim(),
        address: addressController.text.trim(),
        admissionDate: DateTime.now(),
        classId: selectedClassObj.id,
        className: selectedClass.value,
        section: selectedSection.value,
        admissionFees: double.parse(admissionFeesController.text),
        monthlyFees: double.parse(monthlyFeesController.text),
      );

      print(
        'NewAdmissionController: Created student model: ${student.studentName}',
      );

      // Save to database
      final studentId = await StudentService.addStudent(student);
      print('NewAdmissionController: Student saved with ID: $studentId');

      // Update class total students count
      if (selectedClassObj.id != null) {
        final newCount = selectedClassObj.totalStudents + 1;
        await ClassService.updateClassTotalStudents(
          selectedClassObj.id!,
          newCount,
        );
        print(
          'NewAdmissionController: Updated class total students to $newCount',
        );
      }

      // Close dialog
      Get.back();

      // Show success dialog
      Future.delayed(const Duration(milliseconds: 300), () {
        ResultDialog.showSuccess(
          Get.context!,
          title: '🎉 Admission Successful!',
          message:
              'Student ${student.studentName} has been successfully admitted to ${student.className} - ${student.section}. All records have been saved.',
        );
      });

      // Refresh lists and reset form
      Future.delayed(const Duration(seconds: 2), () {
        // Refresh student list if controller exists
        if (Get.isRegistered<StudentsController>()) {
          final studentsController = Get.find<StudentsController>();
          studentsController.refreshStudents();
        }

        // Refresh class list if controller exists
        if (Get.isRegistered<ClassesController>()) {
          final classesController = Get.find<ClassesController>();
          classesController.fetchClasses();
        }

        resetForm();
      });
    } catch (e, stackTrace) {
      print('NewAdmissionController: Error during admission: $e');
      print('NewAdmissionController: Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to complete admission: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> loadClasses() async {
    try {
      isLoadingClasses.value = true;
      print('NewAdmissionController: Loading classes from database');

      availableClasses.value = await ClassService.getAllClasses();
      print(
        'NewAdmissionController: Loaded ${availableClasses.length} classes',
      );

      // Extract unique class names
      final uniqueClasses =
          availableClasses
              .map((classItem) => classItem.className)
              .toSet()
              .toList()
            ..sort();
      classOptions.value = uniqueClasses;

      print('NewAdmissionController: Available classes: $uniqueClasses');

      // Reset selections if current selections are not available
      if (!classOptions.contains(selectedClass.value)) {
        selectedClass.value = '';
        selectedSection.value = '';
        sectionOptions.clear();
      }
    } catch (e, stackTrace) {
      print('NewAdmissionController: Error loading classes: $e');
      print('NewAdmissionController: Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to load classes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingClasses.value = false;
    }
  }

  void onClassChanged(String? newClass) {
    if (newClass != null && newClass.isNotEmpty) {
      selectedClass.value = newClass;

      // Filter sections for the selected class
      final sectionsForClass =
          availableClasses
              .where((classItem) => classItem.className == newClass)
              .map((classItem) => classItem.section)
              .toSet()
              .toList()
            ..sort();

      sectionOptions.value = sectionsForClass;
      print(
        'NewAdmissionController: Sections for $newClass: $sectionsForClass',
      );

      // Reset section if current selection is not available
      if (!sectionOptions.contains(selectedSection.value)) {
        selectedSection.value = '';
      }
    } else {
      selectedClass.value = '';
      sectionOptions.clear();
      selectedSection.value = '';
    }
  }

  void onSectionChanged(String? newSection) {
    selectedSection.value = newSection ?? '';
  }

  void resetForm() {
    currentStep.value = 0;

    // Clear all controllers
    rollNoController.clear();
    grNoController.clear();
    studentNameController.clear();
    fatherNameController.clear();
    casteController.clear();
    placeOfBirthController.clear();
    addressController.clear();
    fathersContactController.clear();
    mothersContactController.clear();
    admissionFeesController.clear();
    monthlyFeesController.clear();

    // Reset reactive values
    dateOfBirth.value = DateTime.now().subtract(const Duration(days: 365 * 6));
    dateOfBirthInWords.value = '';
    selectedGender.value = 'Male';
    selectedReligion.value = 'Muslim';
    selectedClass.value = '';
    selectedSection.value = '';

    _updateDateOfBirthInWords();
  }

  // Validation methods
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required';
    }
    // Basic phone validation (Pakistani format) - allow dashes
    final phoneRegex = RegExp(r'^\+92-\d{3}-\d{7}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (+92-XXX-XXXXXXX)';
    }
    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }
}
