import '../../../data/database_service.dart';
import '../../../data/models/student_model.dart';
import '../../../features/fees/service/monthly_fees_service.dart';

class StudentService {
  static Future<int> addStudent(StudentModel studentModel) async {
    try {
      print(
        'StudentService: Adding student: ${studentModel.studentName}, Roll No: ${studentModel.rollNo}',
      );
      final db = await DatabaseService.database;

      // Create student data with created_at timestamp
      final studentData = {
        ...studentModel.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final id = await db.insert('students', studentData);
      print('StudentService: Successfully added student with ID: $id');

      // Create a student model with the ID and created_at for auto-generation
      final studentWithId = studentModel.copyWith(
        id: id,
        createdAt: DateTime.now(),
      );

      // Auto-generate monthly fees for the new student if applicable
      try {
        await MonthlyFeesService.autoGenerateMonthlyFeesForNewStudent(
          studentWithId,
        );
      } catch (e) {
        print(
          'StudentService: Warning - Failed to auto-generate monthly fees: $e',
        );
        // Don't fail the student creation if fee generation fails
      }

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

  static Future<String> getNextRollNumber() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query('students', columns: ['roll_no']);
      print(
        'StudentService: Found ${result.length} existing students for roll number generation',
      );

      int maxNumber = 0;
      for (var row in result) {
        String rollNo = row['roll_no'] as String;
        print('StudentService: Checking roll number: $rollNo');
        int? num;
        if (rollNo.startsWith('BMS-')) {
          String numStr = rollNo.substring(4);
          num = int.tryParse(numStr);
        } else {
          num = int.tryParse(rollNo);
        }
        if (num != null && num > maxNumber) {
          maxNumber = num;
        }
      }

      int nextNumber = maxNumber + 1;
      String generatedRollNo = 'BMS-${nextNumber.toString().padLeft(5, '0')}';
      print('StudentService: Generated next roll number: $generatedRollNo');
      return generatedRollNo;
    } catch (e, stackTrace) {
      print('StudentService: Error generating next roll number: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> getNextGrNumber() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query('students', columns: ['gr_no']);
      print(
        'StudentService: Found ${result.length} existing students for GR number generation',
      );

      int maxNumber = 0;
      for (var row in result) {
        String? grNo = row['gr_no'] as String?;
        if (grNo != null && grNo.isNotEmpty) {
          print('StudentService: Checking GR number: $grNo');
          int? num = int.tryParse(grNo);
          if (num != null && num > maxNumber) {
            maxNumber = num;
          }
        }
      }

      int nextNumber = maxNumber + 1;
      String generatedGrNo = nextNumber.toString().padLeft(6, '0');
      print('StudentService: Generated next GR number: $generatedGrNo');
      return generatedGrNo;
    } catch (e, stackTrace) {
      print('StudentService: Error generating next GR number: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> bulkInsertStudents(List<StudentModel> students) async {
    try {
      print(
        'StudentService: Starting bulk insert of ${students.length} students',
      );
      final db = await DatabaseService.database;

      // Use batch for efficient bulk insert
      final batch = db.batch();

      for (final student in students) {
        batch.insert('students', student.toJson());
      }

      await batch.commit(noResult: true);
      print(
        'StudentService: Successfully bulk inserted ${students.length} students',
      );
    } catch (e, stackTrace) {
      print('StudentService: Error bulk inserting students: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> getStudentCount() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM students',
      );
      return result.isNotEmpty ? result.first['count'] as int : 0;
    } catch (e, stackTrace) {
      print('StudentService: Error getting student count: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<int> getAdmissionsThisMonth() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(
        now.year,
        now.month + 1,
        1,
      ).subtract(const Duration(days: 1));

      final db = await DatabaseService.database;
      final result = await db.query(
        'students',
        where: 'created_at >= ? AND created_at <= ?',
        whereArgs: [
          startOfMonth.toIso8601String(),
          endOfMonth.toIso8601String(),
        ],
      );

      return result.length;
    } catch (e, stackTrace) {
      print('StudentService: Error getting admissions this month: $e');
      print('StudentService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
