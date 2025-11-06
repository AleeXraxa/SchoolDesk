import '../../../data/database_service.dart';
import '../../../data/models/monthly_payment_history_model.dart';

class MonthlyPaymentHistoryService {
  static Future<int> addPaymentHistory(
    MonthlyPaymentHistoryModel payment,
  ) async {
    try {
      final db = await DatabaseService.database;
      final id = await db.insert('monthly_payment_history', payment.toJson());
      return id;
    } catch (e, stackTrace) {
      print('MonthlyPaymentHistoryService: Error adding payment history: $e');
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyPaymentHistoryModel>> getPaymentsByMonthlyFeeId(
    int monthlyFeeId,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT mph.*, mf.month, s.student_name, s.roll_no
        FROM monthly_payment_history mph
        LEFT JOIN monthly_fees mf ON mph.monthly_fee_id = mf.id
        LEFT JOIN students s ON mf.student_id = s.id
        WHERE mph.monthly_fee_id = ?
        ORDER BY mph.payment_date DESC
      ''',
        [monthlyFeeId],
      );
      return result
          .map((json) => MonthlyPaymentHistoryModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      print(
        'MonthlyPaymentHistoryService: Error fetching payments by monthly fee ID: $e',
      );
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<double> getTotalPaidByMonthlyFeeId(int monthlyFeeId) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        'SELECT SUM(paid_amount) as total FROM monthly_payment_history WHERE monthly_fee_id = ?',
        [monthlyFeeId],
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e, stackTrace) {
      print(
        'MonthlyPaymentHistoryService: Error calculating total paid by monthly fee ID: $e',
      );
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<MonthlyPaymentHistoryModel>> getAllPaymentHistory() async {
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
        'MonthlyPaymentHistoryService: Error fetching all payment history: $e',
      );
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deletePaymentHistory(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'monthly_payment_history',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('MonthlyPaymentHistoryService: Error deleting payment history: $e');
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<double> getTotalPaidForCurrentMonth() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        "SELECT SUM(paid_amount) as total FROM monthly_payment_history WHERE substr(payment_date, 1, 7) = strftime('%Y-%m', 'now')",
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e, stackTrace) {
      print(
        'MonthlyPaymentHistoryService: Error calculating total paid for current month: $e',
      );
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<double> getTotalRevenue() async {
    try {
      final db = await DatabaseService.database;

      double total = 0.0;

      // Sum from monthly payment history
      try {
        final monthlyResult = await db.rawQuery(
          "SELECT SUM(paid_amount) as total FROM monthly_payment_history",
        );
        if (monthlyResult.isNotEmpty && monthlyResult.first['total'] != null) {
          total += (monthlyResult.first['total'] as num).toDouble();
        }
      } catch (e) {
        // Table might not exist, skip
      }

      // Sum from admission fees
      try {
        final admissionResult = await db.rawQuery(
          "SELECT SUM(amount_paid) as total FROM paid_admission_fees",
        );
        if (admissionResult.isNotEmpty &&
            admissionResult.first['total'] != null) {
          total += (admissionResult.first['total'] as num).toDouble();
        }
      } catch (e) {
        // Table might not exist, skip
      }

      // Sum from misc fees
      try {
        final miscResult = await db.rawQuery(
          "SELECT SUM(paid_amount) as total FROM misc_paid_fees",
        );
        if (miscResult.isNotEmpty && miscResult.first['total'] != null) {
          total += (miscResult.first['total'] as num).toDouble();
        }
      } catch (e) {
        // Table might not exist, skip
      }

      // Sum from exam fees
      try {
        final examResult = await db.rawQuery(
          "SELECT SUM(paid_amount) as total FROM exam_paid_fees",
        );
        if (examResult.isNotEmpty && examResult.first['total'] != null) {
          total += (examResult.first['total'] as num).toDouble();
        }
      } catch (e) {
        // Table might not exist, skip
      }

      return total;
    } catch (e, stackTrace) {
      print(
        'MonthlyPaymentHistoryService: Error calculating total revenue: $e',
      );
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<Map<int, double>> getDailyRevenueForMonth(
    int year,
    int month,
  ) async {
    try {
      final db = await DatabaseService.database;
      final monthStr =
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

      // Get all payment dates and amounts for the month
      final results = <Map<String, dynamic>>[];

      // From monthly payments
      try {
        final monthlyResults = await db.rawQuery(
          "SELECT substr(payment_date, 9, 2) as day, SUM(paid_amount) as amount FROM monthly_payment_history WHERE substr(payment_date, 1, 7) = ? GROUP BY substr(payment_date, 9, 2)",
          [monthStr],
        );
        results.addAll(monthlyResults);
      } catch (e) {
        // Table might not exist
      }

      // From admission payments
      try {
        final admissionResults = await db.rawQuery(
          "SELECT substr(payment_date, 9, 2) as day, SUM(amount_paid) as amount FROM paid_admission_fees WHERE substr(payment_date, 1, 7) = ? GROUP BY substr(payment_date, 9, 2)",
          [monthStr],
        );
        results.addAll(admissionResults);
      } catch (e) {
        // Table might not exist
      }

      // From misc payments
      try {
        final miscResults = await db.rawQuery(
          "SELECT substr(payment_date, 9, 2) as day, SUM(paid_amount) as amount FROM misc_paid_fees WHERE substr(payment_date, 1, 7) = ? GROUP BY substr(payment_date, 9, 2)",
          [monthStr],
        );
        results.addAll(miscResults);
      } catch (e) {
        // Table might not exist
      }

      // From exam payments
      try {
        final examResults = await db.rawQuery(
          "SELECT substr(payment_date, 9, 2) as day, SUM(paid_amount) as amount FROM exam_paid_fees WHERE substr(payment_date, 1, 7) = ? GROUP BY substr(payment_date, 9, 2)",
          [monthStr],
        );
        results.addAll(examResults);
      } catch (e) {
        // Table might not exist
      }

      // Aggregate by day
      final dailyRevenue = <int, double>{};
      for (final result in results) {
        final day = int.tryParse(result['day'] as String? ?? '0') ?? 0;
        final amount = (result['amount'] as num?)?.toDouble() ?? 0.0;
        dailyRevenue[day] = (dailyRevenue[day] ?? 0.0) + amount;
      }

      return dailyRevenue;
    } catch (e, stackTrace) {
      print(
        'MonthlyPaymentHistoryService: Error calculating daily revenue for month: $e',
      );
      print('MonthlyPaymentHistoryService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
