import '../../../data/database_service.dart';
import '../../../data/models/monthly_fee_model.dart';
import '../../../data/models/monthly_payment_history_model.dart';
import '../../../data/models/monthly_paid_fees_model.dart';
import '../../../data/models/student_model.dart';
import 'monthly_payment_history_service.dart';

class MonthlyFeesService {
  static Future<int> addMonthlyFee(MonthlyFeeModel fee) async {
    try {
      final db = await DatabaseService.database;
      final id = await db.insert('monthly_fees', fee.toJson());
      return id;
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error adding monthly fee: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyFeeModel>> getAllMonthlyFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        ORDER BY mf.created_at DESC
      ''');
      return result.map((json) => MonthlyFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error fetching monthly fees: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyFeeModel>> getPendingMonthlyFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE mf.status IN ('Pending', 'Partial')
        ORDER BY mf.month DESC, mf.created_at DESC
      ''');
      return result.map((json) => MonthlyFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error fetching pending monthly fees: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyFeeModel>> getPaidMonthlyFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE mf.status = 'Paid'
        ORDER BY mf.month DESC, mf.updated_at DESC
      ''');
      return result.map((json) => MonthlyFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error fetching paid monthly fees: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<MonthlyFeeModel?> getMonthlyFeeById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE mf.id = ?
      ''',
        [id],
      );
      if (result.isNotEmpty) {
        return MonthlyFeeModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error fetching monthly fee by ID: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyFeeModel>> getMonthlyFeesByStudentId(
    int studentId,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE mf.student_id = ?
        ORDER BY mf.month DESC
      ''',
        [studentId],
      );
      return result.map((json) => MonthlyFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error fetching monthly fees by student ID: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateMonthlyFee(MonthlyFeeModel fee) async {
    try {
      if (fee.id == null) return false;
      final db = await DatabaseService.database;
      final result = await db.update(
        'monthly_fees',
        {...fee.toJson(), 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [fee.id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error updating monthly fee: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> processPartialPayment(
    int feeId,
    double paymentAmount,
    String modeOfPayment,
    String? remarks,
  ) async {
    try {
      final db = await DatabaseService.database;

      // Get current fee
      final currentFee = await getMonthlyFeeById(feeId);
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
      // if paid amount > 0 but < total, mark as Partial
      String newStatus;
      if (newPaidAmount >= currentFee.amount) {
        newStatus = 'Paid';
      } else if (newPaidAmount > 0) {
        newStatus = 'Partial';
      } else {
        newStatus = 'Pending';
      }

      final paymentDate = DateTime.now();

      // Use transaction to ensure data consistency
      await db.transaction((txn) async {
        // 1. Insert payment record into monthly_payment_history table
        final paymentRecord = MonthlyPaymentHistoryModel(
          monthlyFeeId: feeId,
          paidAmount: paymentAmount,
          paymentDate: paymentDate,
          paymentMode: modeOfPayment,
          remarks: remarks,
          createdAt: paymentDate,
        );
        await txn.insert('monthly_payment_history', paymentRecord.toJson());

        // 2. Update monthly_fees table
        await txn.update(
          'monthly_fees',
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
      print('MonthlyFeesService: Error processing partial payment: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deleteMonthlyFee(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'monthly_fees',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error deleting monthly fee: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> generateMonthlyFeesForCurrentMonth() async {
    try {
      final now = DateTime.now();
      final currentMonth = '${_getMonthName(now.month)} ${now.year}';

      // Check if fees already exist for current month
      final existingFees = await _getMonthlyFeesByMonth(currentMonth);
      if (existingFees.isNotEmpty) {
        return 'Monthly fees for $currentMonth have already been generated.';
      }

      // Get all active students
      final db = await DatabaseService.database;
      final students = await db.query(
        'students',
        where: 'status = ?',
        whereArgs: ['Active'],
      );

      int generatedCount = 0;

      // Generate monthly fees for each active student
      for (final student in students) {
        final monthlyFeeAmount = student['monthly_fees'] as double? ?? 0.0;

        if (monthlyFeeAmount > 0) {
          final fee = MonthlyFeeModel(
            studentId: student['id'] as int,
            month: currentMonth,
            amount: monthlyFeeAmount,
            paidAmount: 0.0,
            status: 'Pending',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await addMonthlyFee(fee);
          generatedCount++;
        }
      }

      return 'Monthly fees for $currentMonth have been generated successfully for $generatedCount students.';
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error generating monthly fees: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyFeeModel>> _getMonthlyFeesByMonth(
    String month,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE mf.month = ?
      ''',
        [month],
      );
      return result.map((json) => MonthlyFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error fetching monthly fees by month: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyPaymentHistoryModel>>
  getPaymentHistoryByMonthlyFeeId(int monthlyFeeId) async {
    return MonthlyPaymentHistoryService.getPaymentsByMonthlyFeeId(monthlyFeeId);
  }

  static Future<double> getTotalPaidByMonthlyFeeId(int monthlyFeeId) async {
    return MonthlyPaymentHistoryService.getTotalPaidByMonthlyFeeId(
      monthlyFeeId,
    );
  }

  static Future<List<MonthlyPaymentHistoryModel>>
  getAllMonthlyPaymentHistory() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT mph.*, mf.month, s.student_name, s.roll_no
        FROM monthly_payment_history mph
        LEFT JOIN monthly_fees mf ON mph.monthly_fee_id = mf.id
        LEFT JOIN students s ON mf.student_id = s.id
        ORDER BY mph.payment_date DESC
      ''');
      return result
          .map((json) => MonthlyPaymentHistoryModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error fetching all monthly payment history: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyPaidFeesModel>>
  getAggregatedPaidMonthlyFees() async {
    try {
      // Get all payment history records
      final allPayments = await getAllMonthlyPaymentHistory();

      // Group payments by monthly_fee_id (which represents each student's monthly fee entry)
      final groupedPayments = <int, List<MonthlyPaymentHistoryModel>>{};

      for (final payment in allPayments) {
        final feeId = payment.monthlyFeeId;
        if (!groupedPayments.containsKey(feeId)) {
          groupedPayments[feeId] = [];
        }
        groupedPayments[feeId]!.add(payment);
      }

      // Convert grouped payments to aggregated models
      final aggregatedFees = <MonthlyPaidFeesModel>[];

      for (final entry in groupedPayments.entries) {
        try {
          final aggregatedFee = MonthlyPaidFeesModel.fromPayments(entry.value);

          // Get the monthly fee details to populate class info and total fee amount
          final feeDetails = await getMonthlyFeeById(aggregatedFee.studentId);
          if (feeDetails != null) {
            // Create a new instance with class info and total fee amount
            final updatedFee = MonthlyPaidFeesModel(
              studentId: aggregatedFee.studentId,
              studentName: aggregatedFee.studentName,
              rollNo: aggregatedFee.rollNo,
              className: feeDetails.className,
              section: feeDetails.section,
              month: aggregatedFee.month,
              totalPaidAmount: aggregatedFee.totalPaidAmount,
              totalFeeAmount: feeDetails.amount,
              mostRecentPaymentDate: aggregatedFee.mostRecentPaymentDate,
              paymentCount: aggregatedFee.paymentCount,
              individualPayments: aggregatedFee.individualPayments,
            );
            aggregatedFees.add(updatedFee);
          } else {
            // Fallback to original if fee details not found
            aggregatedFees.add(aggregatedFee);
          }
        } catch (e) {
          print('MonthlyFeesService: Error creating aggregated fee: $e');
        }
      }

      // Sort by most recent payment date
      aggregatedFees.sort(
        (a, b) => b.mostRecentPaymentDate.compareTo(a.mostRecentPaymentDate),
      );

      return aggregatedFees;
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error fetching aggregated paid monthly fees: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyFeeModel>> getPendingMonthlyFeesByClassAndMonth(
    String className,
    String month, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause =
          'mf.status IN (\'Pending\', \'Partial\') AND s.class_name = ? AND mf.month = ?';
      List<dynamic> whereArgs = [className, month];

      if (section != null && section.isNotEmpty) {
        whereClause += ' AND s.section = ?';
        whereArgs.add(section);
      }

      print(
        'MonthlyFeesService: Querying pending fees with whereClause: $whereClause, args: $whereArgs',
      );

      final result = await db.rawQuery('''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE $whereClause
        ORDER BY mf.created_at DESC
      ''', whereArgs);

      print('MonthlyFeesService: Found ${result.length} pending fees records');

      return result.map((json) => MonthlyFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error fetching pending monthly fees by class and month: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyFeeModel>> getPaidMonthlyFeesByClassAndMonth(
    String className,
    String month, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause =
          'mf.status = \'Paid\' AND s.class_name = ? AND mf.month = ?';
      List<dynamic> whereArgs = [className, month];

      if (section != null && section.isNotEmpty) {
        whereClause += ' AND s.section = ?';
        whereArgs.add(section);
      }

      print(
        'MonthlyFeesService: Querying paid fees with whereClause: $whereClause, args: $whereArgs',
      );

      final result = await db.rawQuery('''
        SELECT mf.*, s.student_name, s.roll_no, s.class_name, s.section
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE $whereClause
        ORDER BY mf.updated_at DESC
      ''', whereArgs);

      print('MonthlyFeesService: Found ${result.length} paid fees records');

      return result.map((json) => MonthlyFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error fetching paid monthly fees by class and month: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyPaidFeesModel>>
  getAggregatedPaidMonthlyFeesByClassAndMonth(
    String className,
    String month, {
    String? section,
  }) async {
    try {
      final db = await DatabaseService.database;
      String whereClause =
          'mf.status = \'Paid\' AND s.class_name = ? AND mf.month = ?';
      List<dynamic> whereArgs = [className, month];

      if (section != null && section.isNotEmpty) {
        whereClause += ' AND s.section = ?';
        whereArgs.add(section);
      }

      print(
        'MonthlyFeesService: Querying aggregated paid fees with whereClause: $whereClause, args: $whereArgs',
      );

      final result = await db.rawQuery('''
        SELECT
          mf.student_id,
          s.student_name,
          s.roll_no,
          s.class_name,
          s.section,
          mf.month,
          mf.amount as total_fee_amount,
          SUM(mph.paid_amount) as total_paid_amount,
          MAX(mph.payment_date) as most_recent_payment_date,
          COUNT(mph.id) as payment_count
        FROM monthly_fees mf
        LEFT JOIN students s ON mf.student_id = s.id
        LEFT JOIN monthly_payment_history mph ON mf.id = mph.monthly_fee_id
        WHERE $whereClause
        GROUP BY mf.student_id, mf.month
        ORDER BY MAX(mph.payment_date) DESC
      ''', whereArgs);

      print(
        'MonthlyFeesService: Found ${result.length} aggregated paid fees records',
      );

      final aggregatedFees = <MonthlyPaidFeesModel>[];

      for (final row in result) {
        // Get individual payments for this student and month
        // First get the monthly fee ID for this student and month
        final feeResult = await db.rawQuery(
          '''
          SELECT id FROM monthly_fees
          WHERE student_id = ? AND month = ?
        ''',
          [row['student_id'], month],
        );

        final payments = feeResult.isNotEmpty
            ? await MonthlyPaymentHistoryService.getPaymentsByMonthlyFeeId(
                feeResult.first['id'] as int,
              )
            : <MonthlyPaymentHistoryModel>[];

        aggregatedFees.add(
          MonthlyPaidFeesModel(
            studentId: row['student_id'] as int,
            studentName: row['student_name'] as String?,
            rollNo: row['roll_no'] as String?,
            className: row['class_name'] as String?,
            section: row['section'] as String?,
            month: row['month'] as String,
            totalPaidAmount:
                (row['total_paid_amount'] as num?)?.toDouble() ?? 0.0,
            totalFeeAmount:
                (row['total_fee_amount'] as num?)?.toDouble() ?? 0.0,
            mostRecentPaymentDate: row['most_recent_payment_date'] != null
                ? DateTime.parse(row['most_recent_payment_date'] as String)
                : DateTime.now(),
            paymentCount: (row['payment_count'] as num?)?.toInt() ?? 0,
            individualPayments: payments,
          ),
        );
      }

      return aggregatedFees;
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error fetching aggregated paid monthly fees by class and month: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String?> getLatestGeneratedMonth() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT DISTINCT month
        FROM monthly_fees
        ORDER BY created_at DESC
        LIMIT 1
      ''');

      if (result.isNotEmpty) {
        return result.first['month'] as String;
      }
      return null;
    } catch (e, stackTrace) {
      print('MonthlyFeesService: Error fetching latest generated month: $e');
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> autoGenerateMonthlyFeesForNewStudent(
    StudentModel student,
  ) async {
    try {
      // Skip if student is already synced
      if (student.isMonthlyFeeSynced) {
        print(
          'MonthlyFeesService: Student ${student.studentName} is already synced, skipping auto-generation',
        );
        return;
      }

      // Get the latest generated month
      final latestMonth = await getLatestGeneratedMonth();
      if (latestMonth == null) {
        print(
          'MonthlyFeesService: No monthly fees generated yet, skipping auto-generation for new student',
        );
        return;
      }

      // Parse the latest month to get year and month number
      final monthParts = latestMonth.split(' ');
      if (monthParts.length != 2) {
        print('MonthlyFeesService: Invalid month format: $latestMonth');
        return;
      }

      final monthName = monthParts[0];
      final year = int.tryParse(monthParts[1]);
      if (year == null) {
        print('MonthlyFeesService: Invalid year in month: $latestMonth');
        return;
      }

      // Get month number from name
      final monthNumber = _getMonthNumber(monthName);
      if (monthNumber == null) {
        print('MonthlyFeesService: Invalid month name: $monthName');
        return;
      }

      // Create date for the last day of the latest generated month
      final lastDayOfMonth = DateTime(year, monthNumber + 1, 0);

      // Check if student's admission date is before or on the last day of the latest generated month
      if (student.admissionDate.isAfter(lastDayOfMonth)) {
        print(
          'MonthlyFeesService: Student admitted after latest generated month, skipping auto-generation',
        );
        return;
      }

      // Check if fee already exists for this student and month
      final db = await DatabaseService.database;
      final existingFees = await db.rawQuery(
        '''
        SELECT id FROM monthly_fees
        WHERE student_id = ? AND month = ?
      ''',
        [student.id, latestMonth],
      );

      if (existingFees.isNotEmpty) {
        print(
          'MonthlyFeesService: Fee already exists for student ${student.studentName} for month $latestMonth',
        );
        return;
      }

      // Generate the monthly fee entry
      final fee = MonthlyFeeModel(
        studentId: student.id!,
        month: latestMonth,
        amount: student.monthlyFees,
        paidAmount: 0.0,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addMonthlyFee(fee);

      // Update student's sync status
      await _updateStudentMonthlyFeeSyncStatus(student.id!, true);

      print(
        'MonthlyFeesService: Auto-generated monthly fee for student ${student.studentName} for month $latestMonth',
      );
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error auto-generating monthly fees for new student: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> _updateStudentMonthlyFeeSyncStatus(
    int studentId,
    bool isSynced,
  ) async {
    try {
      final db = await DatabaseService.database;
      await db.update(
        'students',
        {'is_monthly_fee_synced': isSynced ? 1 : 0},
        where: 'id = ?',
        whereArgs: [studentId],
      );
    } catch (e, stackTrace) {
      print(
        'MonthlyFeesService: Error updating student monthly fee sync status: $e',
      );
      print('MonthlyFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static int? _getMonthNumber(String monthName) {
    const monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return monthMap[monthName];
  }

  static String _getMonthName(int month) {
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
    return months[month - 1];
  }
}
