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
}
