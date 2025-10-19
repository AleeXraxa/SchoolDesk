import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/student_service.dart';
import '../../../data/models/student_model.dart';

class StudentsController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<StudentModel> students = <StudentModel>[].obs;
  RxList<StudentModel> filteredStudents = <StudentModel>[].obs;
  RxString searchQuery = ''.obs;
  RxMap<String, String> filters = <String, String>{}.obs;
  RxString sortColumn = ''.obs;
  RxBool sortAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;
      print('StudentsController: Loading students from database');

      students.value = await StudentService.getAllStudents();
      print('StudentsController: Loaded ${students.length} students');

      filteredStudents.value = students;
    } catch (e, stackTrace) {
      print('StudentsController: Error loading students: $e');
      print('StudentsController: Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to load students: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStudents() async {
    await loadStudents();
  }

  void addNewStudent() {
    // TODO: Implement add student functionality
    Get.snackbar(
      'Coming Soon',
      'New student admission feature will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewStudent(String rollNo) {
    // TODO: Implement view student functionality
    Get.snackbar(
      'View Student',
      'Viewing details for student roll no: $rollNo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void editStudent(String rollNo) {
    // TODO: Implement edit student functionality
    Get.snackbar(
      'Edit Student',
      'Editing student roll no: $rollNo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteStudent(String rollNo) {
    // TODO: Implement delete student functionality
    Get.snackbar(
      'Delete Student',
      'Deleting student roll no: $rollNo',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF5252),
      colorText: Colors.white,
    );
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
    var filtered = students.where((student) {
      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesSearch =
            student.rollNo.toLowerCase().contains(query) ||
            student.studentName.toLowerCase().contains(query) ||
            student.fatherName.toLowerCase().contains(query) ||
            student.className.toLowerCase().contains(query) ||
            student.section.toLowerCase().contains(query) ||
            student.fatherContact.toLowerCase().contains(query) ||
            student.motherContact.toLowerCase().contains(query) ||
            student.status.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Column filters
      for (final entry in filters.entries) {
        final column = entry.key;
        final filterValue = entry.value.toLowerCase();
        String studentValue = '';

        switch (column) {
          case 'rollNo':
            studentValue = student.rollNo.toLowerCase();
            break;
          case 'name':
            studentValue = student.studentName.toLowerCase();
            break;
          case 'fatherName':
            studentValue = student.fatherName.toLowerCase();
            break;
          case 'class':
            studentValue = student.className.toLowerCase();
            break;
          case 'contact':
            studentValue = student.fatherContact.toLowerCase();
            break;
          case 'status':
            studentValue = student.status.toLowerCase();
            break;
        }

        if (!studentValue.contains(filterValue)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    if (sortColumn.value.isNotEmpty) {
      filtered.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (sortColumn.value) {
          case 'rollNo':
            aValue = a.rollNo;
            bValue = b.rollNo;
            break;
          case 'name':
            aValue = a.studentName;
            bValue = b.studentName;
            break;
          case 'fatherName':
            aValue = a.fatherName;
            bValue = b.fatherName;
            break;
          case 'class':
            aValue = a.className;
            bValue = b.className;
            break;
          case 'contact':
            aValue = a.fatherContact;
            bValue = b.fatherContact;
            break;
          case 'status':
            aValue = a.status;
            bValue = b.status;
            break;
          default:
            aValue = '';
            bValue = '';
        }

        final comparison = _compareValues(aValue, bValue);
        return sortAscending.value ? comparison : -comparison;
      });
    }

    filteredStudents.value = filtered;
  }

  List<String> getUniqueValues(String column) {
    return students
        .map((student) {
          switch (column) {
            case 'rollNo':
              return student.rollNo;
            case 'name':
              return student.studentName;
            case 'fatherName':
              return student.fatherName;
            case 'class':
              return student.className;
            case 'contact':
              return student.fatherContact;
            case 'status':
              return student.status;
            default:
              return '';
          }
        })
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  void clearFilters() {
    filters.clear();
    searchQuery.value = '';
    sortColumn.value = '';
    sortAscending.value = true;
    filteredStudents.value = students;
  }

  void sortByColumn(String column) {
    if (sortColumn.value == column) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
    applyFilters();
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
