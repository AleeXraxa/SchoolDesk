import '../../../data/database_service.dart';
import '../../../data/models/admission_fee_model.dart';

class AdmissionFeesService {
  static Future<int> addAdmissionFee(AdmissionFeeModel fee) async {
    try {
      final db = await DatabaseService.database;
      final id = await db.insert('admission_fees', fee.toJson());
      return id;
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error adding admission fee: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<AdmissionFeeModel>> getAllAdmissionFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT af.*, s.student_name, s.roll_no
        FROM admission_fees af
        LEFT JOIN students s ON af.student_id = s.id
        ORDER BY af.created_at DESC
      ''');
      return result.map((json) => AdmissionFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error fetching admission fees: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<AdmissionFeeModel>> getPendingAdmissionFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT af.*, s.student_name, s.roll_no
        FROM admission_fees af
        LEFT JOIN students s ON af.student_id = s.id
        WHERE af.status = 'Pending'
        ORDER BY af.due_date ASC, af.created_at DESC
      ''');
      return result.map((json) => AdmissionFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error fetching pending admission fees: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<AdmissionFeeModel>> getPaidAdmissionFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT af.*, s.student_name, s.roll_no
        FROM admission_fees af
        LEFT JOIN students s ON af.student_id = s.id
        WHERE af.status = 'Paid'
        ORDER BY af.payment_date DESC, af.updated_at DESC
      ''');
      return result.map((json) => AdmissionFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error fetching paid admission fees: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<AdmissionFeeModel?> getAdmissionFeeById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT af.*, s.student_name, s.roll_no
        FROM admission_fees af
        LEFT JOIN students s ON af.student_id = s.id
        WHERE af.id = ?
      ''',
        [id],
      );
      if (result.isNotEmpty) {
        return AdmissionFeeModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error fetching admission fee by ID: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<AdmissionFeeModel>> getAdmissionFeesByStudentId(
    int studentId,
  ) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT af.*, s.student_name, s.roll_no
        FROM admission_fees af
        LEFT JOIN students s ON af.student_id = s.id
        WHERE af.student_id = ?
        ORDER BY af.created_at DESC
      ''',
        [studentId],
      );
      return result.map((json) => AdmissionFeeModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print(
        'AdmissionFeesService: Error fetching admission fees by student ID: $e',
      );
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateAdmissionFee(AdmissionFeeModel fee) async {
    try {
      if (fee.id == null) return false;
      final db = await DatabaseService.database;
      final result = await db.update(
        'admission_fees',
        {...fee.toJson(), 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [fee.id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error updating admission fee: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> processPayment(int feeId, double paymentAmount) async {
    try {
      final db = await DatabaseService.database;

      // Get current fee
      final currentFee = await getAdmissionFeeById(feeId);
      if (currentFee == null) return false;

      // Validate payment amount doesn't exceed remaining amount
      if (paymentAmount > currentFee.remainingAmount) {
        throw Exception('Payment amount cannot exceed remaining balance');
      }

      // Calculate new amounts
      final newAmountPaid = currentFee.amountPaid + paymentAmount;
      final newRemainingAmount = currentFee.amountDue - newAmountPaid;

      // Ensure remaining amount never goes negative
      final finalRemainingAmount = newRemainingAmount < 0
          ? 0.0
          : newRemainingAmount;

      // Determine status: if remaining amount is 0 or less, mark as Paid
      final newStatus = finalRemainingAmount <= 0 ? 'Paid' : 'Pending';
      final paymentDate = DateTime.now();

      // Update fee - amount_due remains the original admission fee amount
      // remainingAmount is calculated as amountDue - amountPaid
      final result = await db.update(
        'admission_fees',
        {
          'amount_paid': newAmountPaid,
          // amount_due stays the same (original admission fee)
          'status': newStatus,
          'payment_date': paymentDate.toIso8601String(),
          'updated_at': paymentDate.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [feeId],
      );

      return result > 0;
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error processing payment: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deleteAdmissionFee(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'admission_fees',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error deleting admission fee: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> createAdmissionFeeForStudent(
    int studentId,
    double admissionFeeAmount,
  ) async {
    try {
      final dueDate = DateTime.now().add(const Duration(days: 30));
      final fee = AdmissionFeeModel(
        studentId: studentId,
        amountDue: admissionFeeAmount,
        amountPaid: 0.0,
        status: 'Pending',
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await addAdmissionFee(fee);
    } catch (e, stackTrace) {
      print(
        'AdmissionFeesService: Error creating admission fee for student: $e',
      );
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
