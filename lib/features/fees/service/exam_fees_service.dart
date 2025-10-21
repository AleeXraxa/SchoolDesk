import '../../../data/database_service.dart';
import '../../../data/models/exam_fee_model.dart';
import '../../../data/models/exam_paid_fee_model.dart';

class ExamFeesService {
  static Future<int> addExamFee(ExamFeeModel fee) async {
    try {
      final db = await DatabaseService.database;
      final id = await db.insert('exam_fees_pending', fee.toJson());
      return id;
    } catch (e, stackTrace) {
      print('ExamFeesService: Error adding exam fee: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExamFeeModel>> getAllExamFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_pending efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        ORDER BY efp.created_at DESC
      ''');
      return result.map((json) => ExamFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('ExamFeesService: Error fetching exam fees: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExamFeeModel>> getPendingExamFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_pending efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        WHERE efp.status IN ('Pending', 'Partially Paid')
        ORDER BY efp.due_date ASC, efp.created_at DESC
      ''');
      return result.map((json) => ExamFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('ExamFeesService: Error fetching pending exam fees: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExamPaidFeeModel>> getPaidExamFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_paid efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        ORDER BY efp.payment_date DESC
      ''');
      return result.map((json) => ExamPaidFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('ExamFeesService: Error fetching paid exam fees: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<ExamFeeModel?> getExamFeeById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_pending efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        WHERE efp.id = ?
      ''',
        [id],
      );
      if (result.isNotEmpty) {
        return ExamFeeModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('ExamFeesService: Error fetching exam fee by ID: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateExamFee(ExamFeeModel fee) async {
    try {
      if (fee.id == null) return false;
      final db = await DatabaseService.database;
      final result = await db.update(
        'exam_fees_pending',
        {...fee.toJson(), 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [fee.id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('ExamFeesService: Error updating exam fee: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> processPartialPayment(
    int feeId,
    double paymentAmount,
    String paymentMode,
  ) async {
    try {
      final db = await DatabaseService.database;

      // Get current fee
      final currentFee = await getExamFeeById(feeId);
      if (currentFee == null) return false;

      // Validate payment amount doesn't exceed remaining amount
      if (paymentAmount > currentFee.remainingAmount) {
        throw Exception('Payment amount cannot exceed remaining balance');
      }

      // Validate payment amount is positive
      if (paymentAmount <= 0) {
        throw Exception('Payment amount must be greater than zero');
      }

      // Calculate new amounts
      final newPaidAmount = currentFee.paidAmount + paymentAmount;

      // Determine status: if paid amount equals total amount, mark as Paid
      // if paid amount > 0 but < total, mark as Partially Paid
      String newStatus;
      if (newPaidAmount >= currentFee.totalFee) {
        newStatus = 'Paid';
      } else if (newPaidAmount > 0) {
        newStatus = 'Partially Paid';
      } else {
        newStatus = 'Pending';
      }

      final paymentDate = DateTime.now();

      // Use transaction to ensure data consistency
      await db.transaction((txn) async {
        // 1. Insert payment record into exam_fees_paid table
        final paymentRecord = ExamPaidFeeModel(
          pendingExamFeeId: feeId,
          studentId: currentFee.studentId,
          classId: currentFee.classId,
          examName: currentFee.examName,
          paidAmount: paymentAmount,
          paymentDate: paymentDate,
          paymentMode: paymentMode,
          createdAt: paymentDate,
        );
        await txn.insert('exam_fees_paid', paymentRecord.toJson());

        // 2. Update exam_fees_pending table
        await txn.update(
          'exam_fees_pending',
          {
            'paid_amount': newPaidAmount,
            'status': newStatus,
            'updated_at': paymentDate.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [feeId],
        );
      });

      return true;
    } catch (e, stackTrace) {
      print('ExamFeesService: Error processing partial payment: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deleteExamFee(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'exam_fees_pending',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('ExamFeesService: Error deleting exam fee: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> generateExamFeesForClasses(
    String examName,
    String examMonth,
    Map<int, double> classFees,
  ) async {
    try {
      final db = await DatabaseService.database;
      int generatedCount = 0;
      final errors = <String>[];

      // Generate exam fees for each selected class
      for (final entry in classFees.entries) {
        final classId = entry.key;
        final feeAmount = entry.value;

        try {
          // Check if exam fees already exist for this class and exam
          final existingFees = await _getExamFeesByClassAndExam(
            classId,
            examName,
            examMonth,
          );
          if (existingFees.isNotEmpty) {
            // Get class name for better error message
            final classInfo = await db.query(
              'classes',
              where: 'id = ?',
              whereArgs: [classId],
            );
            final className = classInfo.isNotEmpty
                ? '${classInfo.first['class_name']} ${classInfo.first['section']}'
                : 'Unknown Class';

            errors.add(
              'Exam fees for "$examName" - "$examMonth" already generated for $className',
            );
            continue;
          }

          // Get all active students in this class
          final students = await db.query(
            'students',
            where: 'class_id = ? AND status = ?',
            whereArgs: [classId, 'Active'],
          );

          for (final student in students) {
            final fee = ExamFeeModel(
              studentId: student['id'] as int,
              classId: classId,
              examName: examName,
              examMonth: examMonth,
              totalFee: feeAmount,
              paidAmount: 0.0,
              status: 'Pending',
              dueDate: DateTime.now().add(
                Duration(days: 30),
              ), // 30 days from now
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await addExamFee(fee);
            generatedCount++;
          }
        } catch (e) {
          print(
            'ExamFeesService: Error generating fees for class $classId: $e',
          );
          errors.add('Failed to generate fees for class $classId: $e');
        }
      }

      // Build result message
      String message =
          'Exam fees for "$examName" have been generated successfully for $generatedCount students.';

      if (errors.isNotEmpty) {
        message += '\n\nWarnings:\n${errors.join('\n')}';
      }

      return message;
    } catch (e, stackTrace) {
      print('ExamFeesService: Error generating exam fees: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExamFeeModel>> _getExamFeesByExamName(
    String examName,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_pending efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        WHERE efp.exam_name = ?
      ''',
        [examName],
      );
      return result.map((json) => ExamFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('ExamFeesService: Error fetching exam fees by exam name: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExamFeeModel>> _getExamFeesByClassAndExam(
    int classId,
    String examName,
    String examMonth,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_pending efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        WHERE efp.class_id = ? AND efp.exam_name = ? AND efp.exam_month = ?
      ''',
        [classId, examName, examMonth],
      );
      return result.map((json) => ExamFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('ExamFeesService: Error fetching exam fees by class and exam: $e');
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExamFeeModel>> getPendingExamFeesByClassAndExam(
    String className,
    String examName, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause =
          'efp.status IN (\'Pending\', \'Partially Paid\') AND c.class_name = ? AND efp.exam_name = ?';
      List<dynamic> whereArgs = [className, examName];

      if (section != null && section.isNotEmpty) {
        whereClause += ' AND c.section = ?';
        whereArgs.add(section);
      }

      print(
        'ExamFeesService: Querying pending exam fees with whereClause: $whereClause, args: $whereArgs',
      );

      final result = await db.rawQuery('''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_pending efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        WHERE $whereClause
        ORDER BY efp.due_date ASC, efp.created_at DESC
      ''', whereArgs);

      print(
        'ExamFeesService: Found ${result.length} pending exam fees records',
      );

      return result.map((json) => ExamFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'ExamFeesService: Error fetching pending exam fees by class and exam: $e',
      );
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExamPaidFeeModel>> getPaidExamFeesByClassAndExam(
    String className,
    String examName, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause = 'c.class_name = ? AND efp.exam_name = ?';
      List<dynamic> whereArgs = [className, examName];

      if (section != null && section.isNotEmpty) {
        whereClause += ' AND c.section = ?';
        whereArgs.add(section);
      }

      print(
        'ExamFeesService: Querying paid exam fees with whereClause: $whereClause, args: $whereArgs',
      );

      final result = await db.rawQuery('''
        SELECT efp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM exam_fees_paid efp
        LEFT JOIN students s ON efp.student_id = s.id
        LEFT JOIN classes c ON efp.class_id = c.id
        WHERE $whereClause
        ORDER BY efp.payment_date DESC
      ''', whereArgs);

      print('ExamFeesService: Found ${result.length} paid exam fees records');

      return result.map((json) => ExamPaidFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'ExamFeesService: Error fetching paid exam fees by class and exam: $e',
      );
      print('ExamFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static String _getCurrentMonth() {
    final now = DateTime.now();
    const months = [
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
    return '${months[now.month - 1]} ${now.year}';
  }
}
