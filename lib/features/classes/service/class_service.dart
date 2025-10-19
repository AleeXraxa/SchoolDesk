import '../../../data/database_service.dart';
import '../model/class_model.dart';

class ClassService {
  static Future<int> insertClass(ClassModel classModel) async {
    try {
      print(
        'ClassService: Inserting class: ${classModel.className} - ${classModel.section}',
      );
      final db = await DatabaseService.database;

      // Check for duplicate class-section combination
      final existingClasses = await db.query(
        'classes',
        where: 'class_name = ? AND section = ?',
        whereArgs: [classModel.className, classModel.section],
      );

      if (existingClasses.isNotEmpty) {
        throw Exception('This class and section combination already exists');
      }

      final id = await db.insert('classes', classModel.toJson());
      print('ClassService: Successfully inserted class with ID: $id');
      return id;
    } catch (e, stackTrace) {
      print('ClassService: Error inserting class: $e');
      print('ClassService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ClassModel>> getAllClasses() async {
    try {
      print('ClassService: Fetching all classes from database');
      final db = await DatabaseService.database;

      // Get classes - for now, use the stored total_students value since students table doesn't exist yet
      final result = await db.query('classes', orderBy: 'class_name ASC');

      print('ClassService: Query returned ${result.length} rows');

      final classes = result.map((row) => ClassModel.fromJson(row)).toList();

      print('ClassService: Successfully parsed ${classes.length} classes');
      return classes;
    } catch (e, stackTrace) {
      print('ClassService: Error fetching classes: $e');
      print('ClassService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> deleteClassById(int id) async {
    try {
      print('ClassService: Deleting class with ID: $id');
      final db = await DatabaseService.database;
      final deletedRows = await db.delete(
        'classes',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('ClassService: Deleted $deletedRows rows');
      if (deletedRows == 0) {
        throw Exception('Class with ID $id not found');
      }
    } catch (e, stackTrace) {
      print('ClassService: Error deleting class: $e');
      print('ClassService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> updateClass(ClassModel classModel) async {
    try {
      print(
        'ClassService: Updating class: ${classModel.className} - ${classModel.section} (ID: ${classModel.id})',
      );
      final db = await DatabaseService.database;

      // Check for duplicate class-section combination (excluding current class)
      final existingClasses = await db.query(
        'classes',
        where: 'class_name = ? AND section = ? AND id != ?',
        whereArgs: [classModel.className, classModel.section, classModel.id],
      );

      if (existingClasses.isNotEmpty) {
        throw Exception('This class and section combination already exists');
      }

      final updatedRows = await db.update(
        'classes',
        classModel.toJson(),
        where: 'id = ?',
        whereArgs: [classModel.id],
      );

      print('ClassService: Updated $updatedRows rows');
      if (updatedRows == 0) {
        throw Exception('Class with ID ${classModel.id} not found');
      }
    } catch (e, stackTrace) {
      print('ClassService: Error updating class: $e');
      print('ClassService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<ClassModel?> getClassById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query(
        'classes',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return ClassModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('ClassService: Error fetching class by ID: $e');
      print('ClassService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateClassTotalStudents(
    int classId,
    int newCount,
  ) async {
    try {
      print(
        'ClassService: Updating total students for class ID $classId to $newCount',
      );
      final db = await DatabaseService.database;
      final result = await db.update(
        'classes',
        {'total_students': newCount},
        where: 'id = ?',
        whereArgs: [classId],
      );
      print('ClassService: Successfully updated total students');
      return result > 0;
    } catch (e, stackTrace) {
      print('ClassService: Error updating total students: $e');
      print('ClassService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
