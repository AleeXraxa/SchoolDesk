import '../../../data/database_service.dart';
import '../../../data/models/admission_fee_model.dart';
import '../../../data/models/paid_admission_fee_model.dart';
import 'paid_admission_fees_service.dart';

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

  static Future<bool> processPartialPayment(
    int feeId,
    double paymentAmount,
    String modeOfPayment,
  ) async {
    try {
      final db = await DatabaseService.database;

      // Get current fee
      final currentFee = await getAdmissionFeeById(feeId);
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
      final newAmountPaid = currentFee.amountPaid + paymentAmount;
      final newRemainingAmount = currentFee.admissionFeeTotal - newAmountPaid;

      // Ensure remaining amount never goes negative
      final finalRemainingAmount = newRemainingAmount < 0
          ? 0.0
          : newRemainingAmount;

      // Determine status: if remaining amount is 0 or less, mark as Paid
      final newStatus = finalRemainingAmount <= 0 ? 'Paid' : 'Pending';
      final paymentDate = DateTime.now();

      // Use transaction to ensure data consistency
      await db.transaction((txn) async {
        // 1. Insert payment record into paid_admission_fees table
        final paymentRecord = PaidAdmissionFeeModel(
          studentId: currentFee.studentId,
          amountPaid: paymentAmount,
          paymentDate: paymentDate,
          modeOfPayment: modeOfPayment,
          createdAt: paymentDate,
        );
        await txn.insert('paid_admission_fees', paymentRecord.toJson());

        // 2. Update admission_fees table
        await txn.update(
          'admission_fees',
          {
            'amount_paid': newAmountPaid,
            'status': newStatus,
            'updated_at': paymentDate.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [feeId],
        );
      });

      return true;
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error processing partial payment: $e');
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
      // Check if admission fee already exists for this student
      final existingFees = await getAdmissionFeesByStudentId(studentId);
      if (existingFees.isNotEmpty) {
        print(
          'AdmissionFeesService: Admission fee already exists for student ID: $studentId',
        );
        return; // Don't create duplicate
      }

      final fee = AdmissionFeeModel(
        studentId: studentId,
        amountDue: admissionFeeAmount,
        amountPaid: 0.0,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await addAdmissionFee(fee);
      print(
        'AdmissionFeesService: Successfully created admission fee for student ID: $studentId',
      );
    } catch (e, stackTrace) {
      print(
        'AdmissionFeesService: Error creating admission fee for student: $e',
      );
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<PaidAdmissionFeeModel>> getPaymentHistoryByStudentId(
    int studentId,
  ) async {
    return PaidAdmissionFeesService.getPaymentsByStudentId(studentId);
  }

  static Future<double> getTotalPaidByStudentId(int studentId) async {
    return PaidAdmissionFeesService.getTotalPaidByStudentId(studentId);
  }

  static Future<List<PaidAdmissionFeeModel>> getAllPaidAdmissionFees() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery('''
        SELECT paf.*, s.student_name, s.roll_no, s.admission_date
        FROM paid_admission_fees paf
        LEFT JOIN students s ON paf.student_id = s.id
        ORDER BY paf.payment_date DESC
      ''');
      return result
          .map((json) => PaidAdmissionFeeModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      print('AdmissionFeesService: Error fetching all paid admission fees: $e');
      print('AdmissionFeesService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
