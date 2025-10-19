import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/result_dialog.dart';
import '../model/class_model.dart';
import '../service/class_service.dart';

class ClassesController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<ClassModel> classes = <ClassModel>[].obs;
  RxList<ClassModel> filteredClasses = <ClassModel>[].obs;
  RxString searchQuery = ''.obs;
  RxMap<String, String> filters = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadClasses();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      print('ClassesController: Starting to fetch classes from database');
      final fetchedClasses = await ClassService.getAllClasses();
      print(
        'ClassesController: Successfully loaded ${fetchedClasses.length} classes',
      );

      // Sort classes by className A-Z
      fetchedClasses.sort((a, b) => a.className.compareTo(b.className));

      classes.value = fetchedClasses;
      // Create a new list to avoid reference issues
      filteredClasses.value = List.from(fetchedClasses);
    } catch (e, stackTrace) {
      print('ClassesController: Error loading classes: $e');
      print('ClassesController: Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load classes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadClasses() {
    fetchClasses();
  }

  Future<void> addClass(ClassModel newClass) async {
    try {
      final insertedId = await ClassService.insertClass(newClass);
      final classWithId = ClassModel(
        id: insertedId,
        className: newClass.className,
        section: newClass.section,
        totalStudents: newClass.totalStudents,
      );
      classes.add(classWithId);
      // Create a new list to avoid reference issues
      filteredClasses.value = List.from(classes);

      // Close the Add New Class dialog first
      Get.close(1);

      // Wait for dialog to close completely, then show success dialog
      await Future.delayed(const Duration(milliseconds: 200));

      ResultDialog.showSuccess(
        Get.context!,
        title: 'Class Added Successfully!',
        message:
            '${newClass.className} - ${newClass.section} has been added to the system.',
      );

      // Refresh the class list
      await fetchClasses();
    } catch (e) {
      // Close the Add New Class dialog first
      Get.close(1);

      // Show error dialog after dialog closes
      await Future.delayed(const Duration(milliseconds: 200));

      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Add Class',
        message: e.toString().contains('combination already exists')
            ? 'This class and section combination already exists.'
            : 'Failed to add class: ${e.toString()}',
      );
    }
  }

  void addNewClass(ClassModel newClass) {
    addClass(newClass);
  }

  Future<void> updateClass(ClassModel updatedClass) async {
    try {
      await ClassService.updateClass(updatedClass);

      // Update local lists - create new lists to avoid reference issues
      final index = classes.indexWhere((item) => item.id == updatedClass.id);
      if (index != -1) {
        classes[index] = updatedClass;
        filteredClasses.value = List.from(classes);
      }

      // Close the Add New Class dialog first
      Get.close(1);

      // Wait for dialog to close completely, then show success dialog
      await Future.delayed(const Duration(milliseconds: 200));

      ResultDialog.showSuccess(
        Get.context!,
        title: 'Class Updated Successfully!',
        message:
            '${updatedClass.className} - ${updatedClass.section} has been updated in the system.',
      );

      // Refresh the class list
      await fetchClasses();
    } catch (e) {
      // Close the Add New Class dialog first
      Get.close(1);

      // Show error dialog after dialog closes
      await Future.delayed(const Duration(milliseconds: 200));

      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Update Class',
        message: e.toString().contains('combination already exists')
            ? 'This class and section combination already exists.'
            : 'Failed to update class: ${e.toString()}',
      );
    }
  }

  void viewClass(int? id) {
    if (id == null) return;
    Get.snackbar(
      'View Class',
      'Viewing details for class ID: $id',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void editClass(int? id) {
    if (id == null) return;
    Get.snackbar(
      'Edit Class',
      'Editing class ID: $id',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> deleteClass(int? id) async {
    if (id == null) return;

    try {
      // Delete from database
      await ClassService.deleteClassById(id);

      // Remove from local lists - create new lists to avoid reference issues
      classes.removeWhere((classItem) => classItem.id == id);
      filteredClasses.value = List.from(classes);

      // Show success dialog
      await Future.delayed(const Duration(milliseconds: 200));
      ResultDialog.showSuccess(
        Get.context!,
        title: 'Class Deleted Successfully!',
        message: 'The class has been removed from the system.',
      );
    } catch (e) {
      // Show error dialog
      await Future.delayed(const Duration(milliseconds: 200));
      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Delete Class',
        message: 'Failed to delete the class. Please try again.',
      );
    }
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
    var filtered = classes.where((classItem) {
      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesSearch =
            classItem.className.toLowerCase().contains(query) ||
            classItem.section.toLowerCase().contains(query) ||
            classItem.displayName.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Column filters
      for (final entry in filters.entries) {
        final column = entry.key;
        final filterValue = entry.value.toLowerCase();
        final classValue = column == 'className'
            ? classItem.className.toLowerCase()
            : classItem.section.toLowerCase();
        if (!classValue.contains(filterValue)) {
          return false;
        }
      }

      return true;
    }).toList();

    filteredClasses.value = filtered;
  }

  List<String> getUniqueValues(String column) {
    if (column == 'className') {
      return classes
          .map((classItem) => classItem.className)
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } else if (column == 'section') {
      return classes
          .map((classItem) => classItem.section)
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
    // Create a new list to avoid reference issues
    filteredClasses.value = List.from(classes);
  }
}
