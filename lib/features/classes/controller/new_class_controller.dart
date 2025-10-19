import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/result_dialog.dart';
import '../model/class_model.dart';
import '../controller/classes_controller.dart';

class NewClassController extends GetxController {
  final ClassesController _classesController = Get.find<ClassesController>();

  // Form data
  var className = ''.obs;
  var section = ''.obs;

  // Form validation
  var classNameError = ''.obs;
  var sectionError = ''.obs;

  // Step management
  var currentStep = 0.obs;
  final int totalSteps = 3;

  // Loading state
  var isSubmitting = false.obs;

  // Edit mode
  var isEditing = false.obs;
  ClassModel? editingClass;

  void nextStep() {
    if (validateCurrentStep()) {
      if (currentStep.value < totalSteps - 1) {
        currentStep.value++;
        // Clear errors when moving to next step
        classNameError.value = '';
        sectionError.value = '';
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      // Clear errors when moving to previous step
      classNameError.value = '';
      sectionError.value = '';
    }
  }

  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0: // Class Name step
        return validateClassName();
      case 1: // Section step
        return validateSection();
      case 2: // Review step
        return validateAll();
      default:
        return false;
    }
  }

  bool validateClassName() {
    if (className.value.trim().isEmpty) {
      classNameError.value = 'Class name is required';
      return false;
    }
    if (className.value.trim().length < 2) {
      classNameError.value = 'Class name must be at least 2 characters';
      return false;
    }
    classNameError.value = '';
    return true;
  }

  bool validateSection() {
    if (section.value.trim().isEmpty) {
      sectionError.value = 'Section is required';
      return false;
    }
    if (section.value.trim().length != 1) {
      sectionError.value = 'Section must be a single character (A, B, C, etc.)';
      return false;
    }
    if (!RegExp(r'^[A-Z]$').hasMatch(section.value.trim().toUpperCase())) {
      sectionError.value = 'Section must be a letter (A, B, C, etc.)';
      return false;
    }
    sectionError.value = '';
    return true;
  }

  bool validateAll() {
    return validateClassName() && validateSection();
  }

  Future<void> submitForm() async {
    if (validateAll()) {
      isSubmitting.value = true;

      try {
        if (isEditing.value && editingClass != null) {
          // Update existing class
          final updatedClass = ClassModel(
            id: editingClass!.id,
            className: className.value.trim(),
            section: section.value.trim().toUpperCase(),
            totalStudents: editingClass!.totalStudents,
          );

          // Update class (this handles dialog closing and success dialog)
          await _classesController.updateClass(updatedClass);
        } else {
          // Create new class
          final newClass = ClassModel(
            className: className.value.trim(),
            section: section.value.trim().toUpperCase(),
          );

          // Add to classes list (this handles dialog closing and success dialog)
          await _classesController.addClass(newClass);
        }

        isSubmitting.value = false;
        resetForm();
      } catch (e) {
        isSubmitting.value = false;

        // Close the Add Class dialog first
        Get.back();

        // Show error dialog after dialog closes
        Future.delayed(const Duration(milliseconds: 200), () {
          ResultDialog.showError(
            Get.context!,
            title: 'Duplicate Entry',
            message: e.toString().contains('combination already exists')
                ? 'This class and section combination already exists.'
                : 'Failed to ${isEditing.value ? 'update' : 'create'} class: ${e.toString()}',
          );
        });
      }
    } else {
      // Re-validate all fields to show errors
      validateClassName();
      validateSection();
    }
  }

  void resetForm() {
    className.value = '';
    section.value = '';
    classNameError.value = '';
    sectionError.value = '';
    currentStep.value = 0;
    isSubmitting.value = false;
    isEditing.value = false;
    editingClass = null;
  }

  void setEditMode(ClassModel classToEdit) {
    isEditing.value = true;
    editingClass = classToEdit;
    className.value = classToEdit.className;
    section.value = classToEdit.section;
    currentStep.value = 0;
    classNameError.value = '';
    sectionError.value = '';
  }

  String getStepTitle() {
    switch (currentStep.value) {
      case 0:
        return 'Class Information';
      case 1:
        return 'Section Details';
      case 2:
        return 'Review & Confirm';
      default:
        return 'New Class';
    }
  }

  String getStepSubtitle() {
    switch (currentStep.value) {
      case 0:
        return 'Enter the class name';
      case 1:
        return 'Specify the section';
      case 2:
        return 'Review your information before submitting';
      default:
        return '';
    }
  }

  bool get isFirstStep => currentStep.value == 0;
  bool get isLastStep => currentStep.value == totalSteps - 1;
}
