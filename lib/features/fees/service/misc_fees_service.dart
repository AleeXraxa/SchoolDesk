import '../../../data/database_service.dart';
import '../../../data/models/misc_fee_model.dart';
import '../../../data/models/misc_paid_fee_model.dart';

class MiscFeesService {
  static Future<int> addMiscFee(MiscFeeModel fee) async {
    try {
      final db = await DatabaseService.database;
      final id = await db.insert('misc_fees_pending', fee.toJson());
      return id;
    } catch (e, stackTrace) {
      print('MiscFeesService: Error adding misc fee: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscFeeModel>> getAllMiscFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        ORDER BY mfp.created_at DESC
      ''');
      return result.map((json) => MiscFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MiscFeesService: Error fetching misc fees: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscFeeModel>> getPendingMiscFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.status IN ('Pending', 'Partially Paid')
        ORDER BY mfp.due_date ASC, mfp.created_at DESC
      ''');
      return result.map((json) => MiscFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MiscFeesService: Error fetching pending misc fees: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscPaidFeeModel>> getPaidMiscFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_paid mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        ORDER BY mfp.payment_date DESC
      ''');
      return result.map((json) => MiscPaidFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MiscFeesService: Error fetching paid misc fees: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<MiscFeeModel?> getMiscFeeById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.id = ?
      ''',
        [id],
      );
      if (result.isNotEmpty) {
        return MiscFeeModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('MiscFeesService: Error fetching misc fee by ID: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateMiscFee(MiscFeeModel fee) async {
    try {
      if (fee.id == null) return false;
      final db = await DatabaseService.database;
      final result = await db.update(
        'misc_fees_pending',
        {...fee.toJson(), 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [fee.id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('MiscFeesService: Error updating misc fee: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
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
      final currentFee = await getMiscFeeById(feeId);
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
        // 1. Insert payment record into misc_fees_paid table
        final paymentRecord = MiscPaidFeeModel(
          pendingMiscFeeId: feeId,
          studentId: currentFee.studentId,
          classId: currentFee.classId,
          miscFeeType: currentFee.miscFeeType,
          paidAmount: paymentAmount,
          paymentDate: paymentDate,
          paymentMode: paymentMode,
          createdAt: paymentDate,
        );
        await txn.insert('misc_fees_paid', paymentRecord.toJson());

        // 2. Update misc_fees_pending table
        await txn.update(
          'misc_fees_pending',
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
      print('MiscFeesService: Error processing partial payment: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deleteMiscFee(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'misc_fees_pending',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('MiscFeesService: Error deleting misc fee: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> generateMiscFeesForClasses(
    String miscFeeType,
    String month,
    Map<int, double> classFees,
  ) async {
    try {
      final db = await DatabaseService.database;
      int generatedCount = 0;
      final errors = <String>[];

      // Generate misc fees for each selected class
      for (final entry in classFees.entries) {
        final classId = entry.key;
        final feeAmount = entry.value;

        try {
          // Check if misc fees already exist for this class and type/month
          final existingFees = await _getMiscFeesByClassAndType(
            classId,
            miscFeeType,
            month,
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
              'Misc fees for "$miscFeeType" - "$month" already generated for $className',
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
            final fee = MiscFeeModel(
              studentId: student['id'] as int,
              classId: classId,
              miscFeeType: miscFeeType,
              month: month,
              totalFee: feeAmount,
              paidAmount: 0.0,
              status: 'Pending',
              dueDate: DateTime.now().add(
                Duration(days: 30),
              ), // 30 days from now
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await addMiscFee(fee);
            generatedCount++;
          }
        } catch (e) {
          print(
            'MiscFeesService: Error generating fees for class $classId: $e',
          );
          errors.add('Failed to generate fees for class $classId: $e');
        }
      }

      // Build result message
      String message =
          'Misc fees for "$miscFeeType" have been generated successfully for $generatedCount students.';

      if (errors.isNotEmpty) {
        message += '\n\nWarnings:\n${errors.join('\n')}';
      }

      return message;
    } catch (e, stackTrace) {
      print('MiscFeesService: Error generating misc fees: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> generateMiscFeesForStudent(
    int studentId,
    String miscFeeType,
    String month,
    double feeAmount,
    String? description,
  ) async {
    try {
      final db = await DatabaseService.database;

      // Check if misc fees already exist for this student and type/month
      final existingFees = await _getMiscFeesByStudentAndType(
        studentId,
        miscFeeType,
        month,
      );
      if (existingFees.isNotEmpty) {
        throw Exception(
          'Misc fees for "$miscFeeType" - "$month" already exist for this student',
        );
      }

      // Get student info to get class_id
      final studentInfo = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [studentId],
      );
      if (studentInfo.isEmpty) {
        throw Exception('Student not found');
      }

      final classId = studentInfo.first['class_id'] as int;

      final fee = MiscFeeModel(
        studentId: studentId,
        classId: classId,
        miscFeeType: miscFeeType,
        month: month,
        totalFee: feeAmount,
        paidAmount: 0.0,
        status: 'Pending',
        description: description,
        dueDate: DateTime.now().add(Duration(days: 30)), // 30 days from now
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addMiscFee(fee);

      return 'Misc fee for "$miscFeeType" has been generated successfully for the student.';
    } catch (e, stackTrace) {
      print('MiscFeesService: Error generating misc fee for student: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscFeeModel>> _getMiscFeesByType(
    String miscFeeType,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.misc_fee_type = ?
      ''',
        [miscFeeType],
      );
      return result.map((json) => MiscFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MiscFeesService: Error fetching misc fees by type: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscFeeModel>> _getMiscFeesByClassAndType(
    int classId,
    String miscFeeType,
    String month,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.class_id = ? AND mfp.misc_fee_type = ? AND mfp.month = ?
      ''',
        [classId, miscFeeType, month],
      );
      return result.map((json) => MiscFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MiscFeesService: Error fetching misc fees by class and type: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscFeeModel>> _getMiscFeesByStudentAndType(
    int studentId,
    String miscFeeType,
    String month,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.student_id = ? AND mfp.misc_fee_type = ? AND mfp.month = ?
      ''',
        [studentId, miscFeeType, month],
      );
      return result.map((json) => MiscFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MiscFeesService: Error fetching misc fees by student and type: $e',
      );
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscFeeModel>> getPendingMiscFeesByClassAndType(
    String className,
    String miscFeeType, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause =
          'mfp.status IN (\'Pending\', \'Partially Paid\') AND c.class_name = ? AND mfp.misc_fee_type = ?';
      List<dynamic> whereArgs = [className, miscFeeType];

      if (section != null && section.isNotEmpty) {
        whereClause += ' AND c.section = ?';
        whereArgs.add(section);
      }

      print(
        'MiscFeesService: Querying pending misc fees with whereClause: $whereClause, args: $whereArgs',
      );

      final result = await db.rawQuery('''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE $whereClause
        ORDER BY mfp.due_date ASC, mfp.created_at DESC
      ''', whereArgs);

      // Debug: Log the actual query and results for troubleshooting
      print(
        'MiscFeesService: Executed pending query: SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section FROM misc_fees_pending mfp LEFT JOIN students s ON mfp.student_id = s.id LEFT JOIN classes c ON mfp.class_id = c.id WHERE $whereClause ORDER BY mfp.due_date ASC, mfp.created_at DESC',
      );
      print('MiscFeesService: Pending query parameters: $whereArgs');

      print(
        'MiscFeesService: Found ${result.length} pending misc fees records',
      );

      return result.map((json) => MiscFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MiscFeesService: Error fetching pending misc fees by class and type: $e',
      );
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscPaidFeeModel>> getPaidMiscFeesByClassAndType(
    String className,
    String miscFeeType, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause = 'c.class_name = ? AND mfp.misc_fee_type = ?';
      List<dynamic> whereArgs = [className, miscFeeType];

      if (section != null && section.isNotEmpty) {
        whereClause += ' AND c.section = ?';
        whereArgs.add(section);
      }

      print(
        'MiscFeesService: Querying paid misc fees with whereClause: $whereClause, args: $whereArgs',
      );

      final result = await db.rawQuery('''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_paid mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE $whereClause
        ORDER BY mfp.payment_date DESC
      ''', whereArgs);

      print('MiscFeesService: Found ${result.length} paid misc fees records');

      return result.map((json) => MiscPaidFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MiscFeesService: Error fetching paid misc fees by class and type: $e',
      );
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscPaidFeeModel>> getMiscPaidEntriesByStudent(
    int studentId,
    String miscFeeType,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_paid mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE mfp.student_id = ? AND mfp.misc_fee_type = ?
        ORDER BY mfp.payment_date DESC
      ''',
        [studentId, miscFeeType],
      );

      print(
        'MiscFeesService: Found ${result.length} paid misc fee entries for student $studentId, type $miscFeeType',
      );

      return result.map((json) => MiscPaidFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MiscFeesService: Error fetching paid misc fee entries by student: $e',
      );
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscFeeModel>> getPendingMiscFeesByClassAndTypeAndMonth(
    String className,
    String miscFeeType,
    String month, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause = 'mfp.status IN (\'Pending\', \'Partially Paid\')';
      List<dynamic> whereArgs = [];

      // Add class filter if not empty
      if (className.isNotEmpty) {
        whereClause += ' AND c.class_name = ?';
        whereArgs.add(className);
      }

      // Add fee type filter if not empty
      if (miscFeeType.isNotEmpty) {
        whereClause += ' AND mfp.misc_fee_type = ?';
        whereArgs.add(miscFeeType);
      }

      // Add month filter if not empty - support both full format (October 2025) and month-only (October)
      if (month.isNotEmpty) {
        // Extract month name (first word before space, or full string if no space)
        final monthName = month.split(' ').first;
        // Use LIKE to match month name at start of stored value
        whereClause += ' AND mfp.month LIKE ?';
        whereArgs.add('$monthName%');
      }

      // Add section filter if provided
      if (section != null && section.isNotEmpty) {
        whereClause += ' AND c.section = ?';
        whereArgs.add(section);
      }

      print(
        'MiscFeesService: Querying pending misc fees with filters: className="$className", miscFeeType="$miscFeeType", month="$month", section="$section"',
      );
      print('MiscFeesService: SQL Query: WHERE $whereClause, args: $whereArgs');

      final result = await db.rawQuery('''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_pending mfp
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        WHERE $whereClause
        ORDER BY mfp.due_date ASC, mfp.created_at DESC
      ''', whereArgs);

      print(
        'MiscFeesService: Found ${result.length} pending misc fees records',
      );

      // Debug: Log first few results if any
      if (result.isNotEmpty) {
        print('MiscFeesService: Sample pending result: ${result.first}');
      } else {
        // Debug: Check if there are any records in the tables at all
        final totalPending = await db.rawQuery(
          'SELECT COUNT(*) as count FROM misc_fees_pending',
        );
        print(
          'MiscFeesService: Total pending records: ${totalPending.first['count']}',
        );

        // Debug: Check if the specific filters match any data
        if (className.isNotEmpty) {
          final classCheck = await db.rawQuery(
            'SELECT COUNT(*) as count FROM classes WHERE class_name = ?',
            [className],
          );
          print(
            'MiscFeesService: Classes with name "$className": ${classCheck.first['count']}',
          );
        }
        if (miscFeeType.isNotEmpty) {
          final typeCheck = await db.rawQuery(
            'SELECT COUNT(*) as count FROM misc_fees_pending WHERE misc_fee_type = ?',
            [miscFeeType],
          );
          print(
            'MiscFeesService: Pending fees with type "$miscFeeType": ${typeCheck.first['count']}',
          );
        }
        if (month.isNotEmpty) {
          final monthCheck = await db.rawQuery(
            'SELECT COUNT(*) as count FROM misc_fees_pending WHERE month = ?',
            [month],
          );
          print(
            'MiscFeesService: Pending fees with month "$month": ${monthCheck.first['count']}',
          );

          // Also check what months actually exist in the database
          final allMonths = await db.rawQuery(
            'SELECT DISTINCT month FROM misc_fees_pending ORDER BY month',
          );
          print(
            'MiscFeesService: All months in pending fees: ${allMonths.map((m) => m['month']).toList()}',
          );
        }
      }

      return result.map((json) => MiscFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MiscFeesService: Error fetching pending misc fees by class, type and month: $e',
      );
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MiscPaidFeeModel>> getPaidMiscFeesByClassAndTypeAndMonth(
    String className,
    String miscFeeType,
    String month, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause = '';
      List<dynamic> whereArgs = [];

      // Add class filter if not empty
      if (className.isNotEmpty) {
        whereClause += 'c.class_name = ?';
        whereArgs.add(className);
      }

      // Add fee type filter if not empty
      if (miscFeeType.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'mfp.misc_fee_type = ?';
        whereArgs.add(miscFeeType);
      }

      // Add month filter if not empty - this requires JOIN with pending table
      if (month.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        // Extract month name (first word before space, or full string if no space)
        final monthName = month.split(' ').first;
        // Use LIKE to match month name at start of stored value
        whereClause += 'mfp_pending.month LIKE ?';
        whereArgs.add('$monthName%');
      }

      // Add section filter if provided
      if (section != null && section.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'c.section = ?';
        whereArgs.add(section);
      }

      print(
        'MiscFeesService: Querying paid misc fees with filters: className="$className", miscFeeType="$miscFeeType", month="$month", section="$section"',
      );
      print('MiscFeesService: SQL Query: WHERE $whereClause, args: $whereArgs');

      // Always use JOIN with pending table since month filtering requires it
      final result = await db.rawQuery('''
        SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section
        FROM misc_fees_paid mfp
        LEFT JOIN misc_fees_pending mfp_pending ON mfp.pending_misc_fee_id = mfp_pending.id
        LEFT JOIN students s ON mfp.student_id = s.id
        LEFT JOIN classes c ON mfp.class_id = c.id
        ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
        ORDER BY mfp.payment_date DESC
      ''', whereArgs);

      // Debug: Log the actual query and results for troubleshooting
      print(
        'MiscFeesService: Executed query: SELECT mfp.*, s.student_name, s.roll_no, c.class_name, c.section FROM misc_fees_paid mfp LEFT JOIN misc_fees_pending mfp_pending ON mfp.pending_misc_fee_id = mfp_pending.id LEFT JOIN students s ON mfp.student_id = s.id LEFT JOIN classes c ON mfp.class_id = c.id ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''} ORDER BY mfp.payment_date DESC',
      );
      print('MiscFeesService: Query parameters: $whereArgs');

      print(
        'MiscFeesService: Found ${result.length} paid misc fees records with filtering',
      );

      // Debug: Log first few results if any
      if (result.isNotEmpty) {
        print('MiscFeesService: Sample result: ${result.first}');
      } else {
        // Debug: Check if there are any records in the tables at all
        final totalPaid = await db.rawQuery(
          'SELECT COUNT(*) as count FROM misc_fees_paid',
        );
        final totalPending = await db.rawQuery(
          'SELECT COUNT(*) as count FROM misc_fees_pending',
        );
        print(
          'MiscFeesService: Total paid records: ${totalPaid.first['count']}, Total pending records: ${totalPending.first['count']}',
        );

        // Debug: Check if the specific filters match any data
        if (className.isNotEmpty) {
          final classCheck = await db.rawQuery(
            'SELECT COUNT(*) as count FROM classes WHERE class_name = ?',
            [className],
          );
          print(
            'MiscFeesService: Classes with name "$className": ${classCheck.first['count']}',
          );
        }
        if (miscFeeType.isNotEmpty) {
          final typeCheck = await db.rawQuery(
            'SELECT COUNT(*) as count FROM misc_fees_paid WHERE misc_fee_type = ?',
            [miscFeeType],
          );
          print(
            'MiscFeesService: Paid fees with type "$miscFeeType": ${typeCheck.first['count']}',
          );
        }
        if (month.isNotEmpty) {
          final monthCheck = await db.rawQuery(
            'SELECT COUNT(*) as count FROM misc_fees_pending WHERE month = ?',
            [month],
          );
          print(
            'MiscFeesService: Pending fees with month "$month": ${monthCheck.first['count']}',
          );

          // Also check what months actually exist in the database
          final allMonths = await db.rawQuery(
            'SELECT DISTINCT month FROM misc_fees_pending ORDER BY month',
          );
          print(
            'MiscFeesService: All months in pending fees: ${allMonths.map((m) => m['month']).toList()}',
          );
        }
      }

      return result.map((json) => MiscPaidFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MiscFeesService: Error fetching paid misc fees by class, type and month: $e',
      );
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> generateMiscFeesForClass(
    int classId,
    String month,
    String miscFeeType,
    double feeAmount, {
    String? description,
  }) async {
    try {
      final db = await DatabaseService.database;
      int generatedCount = 0;

      // Get all active students in this class
      final students = await db.query(
        'students',
        where: 'class_id = ? AND status = ?',
        whereArgs: [classId, 'Active'],
      );

      for (final student in students) {
        final fee = MiscFeeModel(
          studentId: student['id'] as int,
          classId: classId,
          miscFeeType: miscFeeType,
          month: month,
          totalFee: feeAmount,
          paidAmount: 0.0,
          status: 'Pending',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          description: description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await addMiscFee(fee);
        generatedCount++;
      }

      return 'Misc fees for "$miscFeeType" have been generated successfully for $generatedCount students in the class.';
    } catch (e, stackTrace) {
      print('MiscFeesService: Error generating misc fees for class: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> generateMiscFeeForStudent(
    int studentId,
    String month,
    String miscFeeType,
    double feeAmount, {
    String? description,
  }) async {
    try {
      // Get student details to get class_id
      final db = await DatabaseService.database;
      final studentResult = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [studentId],
      );

      if (studentResult.isEmpty) {
        throw Exception('Student not found');
      }

      final student = studentResult.first;
      final classId = student['class_id'] as int;

      final fee = MiscFeeModel(
        studentId: studentId,
        classId: classId,
        miscFeeType: miscFeeType,
        month: month,
        totalFee: feeAmount,
        paidAmount: 0.0,
        status: 'Pending',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addMiscFee(fee);

      return 'Misc fee for "$miscFeeType" has been generated successfully for the student.';
    } catch (e, stackTrace) {
      print('MiscFeesService: Error generating misc fee for student: $e');
      print('MiscFeesService: Stack trace: $stackTrace');
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
