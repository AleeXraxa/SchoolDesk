import '../../../data/database_service.dart';
import '../../../data/models/student_model.dart';

class StudentService {
  static Future<int> addStudent(StudentModel studentModel) async {
    try {
      print('StudentService: Adding student: ${studentModel.studentName}');
      final db = await DatabaseService.database;
      final id = await db.insert('students', studentModel.toJson());
      print('StudentService: Successfully added student with ID: $id');
      return id;
    } catch (e, stackTrace) {
      print('StudentService: Error adding student: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<StudentModel>> getAllStudents() async {
    try {
      print('StudentService: Fetching all students from database');
      final db = await DatabaseService.database;
      final result = await db.query('students');
      print('StudentService: Query returned ${result.length} rows');
      final students = result
          .map((json) => StudentModel.fromJson(json))
          .toList();
      print('StudentService: Successfully parsed ${students.length} students');
      return students;
    } catch (e, stackTrace) {
      print('StudentService: Error fetching students: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<StudentModel?> getStudentById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return StudentModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('StudentService: Error fetching student by ID: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateStudent(StudentModel studentModel) async {
    try {
      if (studentModel.id == null) return false;
      final db = await DatabaseService.database;
      final result = await db.update(
        'students',
        studentModel.toJson(),
        where: 'id = ?',
        whereArgs: [studentModel.id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('StudentService: Error updating student: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deleteStudent(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('StudentService: Error deleting student: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
