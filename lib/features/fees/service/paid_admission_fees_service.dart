import '../../../data/database_service.dart';
import '../../../data/models/paid_admission_fee_model.dart';

class PaidAdmissionFeesService {
  static Future<int> addPayment(PaidAdmissionFeeModel payment) async {
    try {
      print(
        'PaidAdmissionFeesService: Adding payment: ${payment.amountPaid} for student ${payment.studentId}',
      );
      final db = await DatabaseService.database;
      final id = await db.insert('paid_admission_fees', payment.toJson());
      print(
        'PaidAdmissionFeesService: Successfully added payment with ID: $id',
      );
      return id;
    } catch (e, stackTrace) {
      print('PaidAdmissionFeesService: Error adding payment: $e');
      print('PaidAdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<PaidAdmissionFeeModel>> getPaymentsByStudentId(
    int studentId,
  ) async {
    try {
      print(
        'PaidAdmissionFeesService: Fetching payments for student ID: $studentId',
      );
      final db = await DatabaseService.database;
      final result = await db.query(
        'paid_admission_fees',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'payment_date DESC',
      );
      print(
        'PaidAdmissionFeesService: Query returned ${result.length} payments',
      );
      final payments = result
          .map((json) => PaidAdmissionFeeModel.fromJson(json))
          .toList();
      print(
        'PaidAdmissionFeesService: Successfully parsed ${payments.length} payments',
      );
      return payments;
    } catch (e, stackTrace) {
      print('PaidAdmissionFeesService: Error fetching payments: $e');
      print('PaidAdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<PaidAdmissionFeeModel>> getAllPayments() async {
    try {
      print('PaidAdmissionFeesService: Fetching all payments');
      final db = await DatabaseService.database;
      final result = await db.query(
        'paid_admission_fees',
        orderBy: 'payment_date DESC',
      );
      print(
        'PaidAdmissionFeesService: Query returned ${result.length} payments',
      );
      final payments = result
          .map((json) => PaidAdmissionFeeModel.fromJson(json))
          .toList();
      print(
        'PaidAdmissionFeesService: Successfully parsed ${payments.length} payments',
      );
      return payments;
    } catch (e, stackTrace) {
      print('PaidAdmissionFeesService: Error fetching all payments: $e');
      print('PaidAdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<double> getTotalPaidByStudentId(int studentId) async {
    try {
      final payments = await getPaymentsByStudentId(studentId);
      final total = payments.fold<double>(
        0.0,
        (sum, payment) => sum + payment.amountPaid,
      );
      print(
        'PaidAdmissionFeesService: Total paid by student $studentId: $total',
      );
      return total;
    } catch (e, stackTrace) {
      print('PaidAdmissionFeesService: Error calculating total paid: $e');
      print('PaidAdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deletePayment(int paymentId) async {
    try {
      print('PaidAdmissionFeesService: Deleting payment ID: $paymentId');
      final db = await DatabaseService.database;
      final result = await db.delete(
        'paid_admission_fees',
        where: 'id = ?',
        whereArgs: [paymentId],
      );
      final success = result > 0;
      print(
        'PaidAdmissionFeesService: Payment deletion ${success ? 'successful' : 'failed'}',
      );
      return success;
    } catch (e, stackTrace) {
      print('PaidAdmissionFeesService: Error deleting payment: $e');
      print('PaidAdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
