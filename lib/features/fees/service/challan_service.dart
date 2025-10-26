import '../../../data/database_service.dart';
import '../../../data/models/challan_model.dart';
import 'package:intl/intl.dart';

class ChallanService {
  static final ChallanService _instance = ChallanService._internal();
  factory ChallanService() => _instance;
  ChallanService._internal();

  // Create a new challan
  static Future<bool> createChallan(ChallanModel challan) async {
    try {
      final db = await DatabaseService.database;

      // Validate required fields
      if (challan.studentId.isEmpty ||
          challan.feesType.isEmpty ||
          challan.amount <= 0) {
        print(
          'Error: Invalid challan data - studentId, feesType, and amount are required',
        );
        return false;
      }

      // Ensure student_id is integer
      final studentIdInt = int.tryParse(challan.studentId);
      if (studentIdInt == null) {
        print('Error: studentId must be a valid integer');
        return false;
      }

      // Prepare data map with correct types
      final data = {
        'challan_id': challan.challanId,
        'student_id': studentIdInt,
        'class_id': challan.classId != null
            ? int.tryParse(challan.classId!)
            : null,
        'fees_type': challan.feesType,
        'amount': challan.amount,
        'status': challan.status,
        'date_generated': challan.dateGenerated.toIso8601String(),
        'reference_fee_id': challan.referenceFeeId != null
            ? int.tryParse(challan.referenceFeeId!)
            : null,
        'date_paid': challan.datePaid?.toIso8601String(),
        'payment_mode': challan.paymentMode,
        'remarks': challan.remarks,
        'month': challan.month,
        'exam_details': challan.examDetails,
        'fee_details': challan.feeDetails,
      };

      await db.insert('challans', data);

      // Debug logging
      print('🧾 Challan created successfully:');
      print('  Challan ID: ${challan.challanId}');
      print('  Student ID: ${challan.studentId}');
      print('  Reference Fee ID: ${challan.referenceFeeId}');
      print('  Amount: ${challan.amount}');
      print('  Month: ${challan.month}');
      print('  Fee Type: ${challan.feesType}');
      print('----------------------------');

      return true;
    } catch (e, stackTrace) {
      print('Error creating challan: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Fetch challans by fees type
  static Future<List<ChallanModel>> fetchChallansByType(String feesType) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT challans.*, students.student_name AS student_name, students.roll_no AS roll_no
        FROM challans
        LEFT JOIN students ON challans.student_id = students.id
        WHERE challans.fees_type = ?
        ORDER BY challans.date_generated DESC
      ''',
        [feesType],
      );

      final challans = maps.map((map) => ChallanModel.fromMap(map)).toList();
      print('Fetched $feesType challans: ${challans.length} items');
      for (var challan in challans) {
        print(
          'Challan: ${challan.challanId} - Student: ${challan.studentName ?? 'Unknown'}',
        );
      }

      return challans;
    } catch (e) {
      print('Error fetching challans by type: $e');
      return [];
    }
  }

  // Fetch all challans
  static Future<List<ChallanModel>> fetchAllChallans() async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT challans.*, students.student_name AS student_name, students.roll_no AS roll_no
        FROM challans
        LEFT JOIN students ON challans.student_id = students.id
        ORDER BY challans.date_generated DESC
      ''');

      final challans = maps.map((map) => ChallanModel.fromMap(map)).toList();
      print('Fetched all challans: ${challans.length} items');
      for (var challan in challans) {
        print(
          'Challan: ${challan.challanId} - Student: ${challan.studentName ?? 'Unknown'}',
        );
      }

      return challans;
    } catch (e) {
      print('Error fetching all challans: $e');
      return [];
    }
  }

  // Update challan status
  static Future<bool> updateChallanStatus(
    String challanId,
    String status, {
    DateTime? datePaid,
    String? paymentMode,
    String? remarks,
  }) async {
    try {
      final db = await DatabaseService.database;
      final Map<String, dynamic> updates = {'status': status};

      if (datePaid != null) updates['date_paid'] = datePaid.toIso8601String();
      if (paymentMode != null) updates['payment_mode'] = paymentMode;
      if (remarks != null) updates['remarks'] = remarks;

      final result = await db.update(
        'challans',
        updates,
        where: 'challan_id = ?',
        whereArgs: [challanId],
      );

      return result > 0;
    } catch (e) {
      print('Error updating challan status: $e');
      return false;
    }
  }

  // Get challan by ID
  static Future<ChallanModel?> getChallanById(String challanId) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'challans',
        where: 'challan_id = ?',
        whereArgs: [challanId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return ChallanModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting challan by ID: $e');
      return null;
    }
  }

  // Delete challan
  static Future<bool> deleteChallan(String challanId) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'challans',
        where: 'challan_id = ?',
        whereArgs: [challanId],
      );

      return result > 0;
    } catch (e) {
      print('Error deleting challan: $e');
      return false;
    }
  }

  // Search challans by student name or roll number
  static Future<List<ChallanModel>> searchChallans(
    String query, {
    String? feesType,
  }) async {
    try {
      final db = await DatabaseService.database;

      String whereClause =
          'students.student_name LIKE ? OR students.roll_no LIKE ?';
      List<dynamic> whereArgs = ['%$query%', '%$query%'];

      if (feesType != null) {
        whereClause += ' AND challans.fees_type = ?';
        whereArgs.add(feesType);
      }

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT challans.*, students.student_name AS student_name, students.roll_no AS roll_no
        FROM challans
        LEFT JOIN students ON challans.student_id = students.id
        WHERE $whereClause
        ORDER BY challans.date_generated DESC
      ''', whereArgs);

      final challans = maps.map((map) => ChallanModel.fromMap(map)).toList();
      print(
        'Searched challans: ${challans.length} items found for query: $query',
      );
      for (var challan in challans) {
        print(
          'Challan: ${challan.challanId} - Student: ${challan.studentName ?? 'Unknown'}',
        );
      }

      return challans;
    } catch (e) {
      print('Error searching challans: $e');
      return [];
    }
  }

  // Check if challan exists for a specific fee entry
  static Future<bool> challanExistsForFee(String feeId) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'challans',
        where: 'reference_fee_id = ?',
        whereArgs: [feeId],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking challan existence for fee $feeId: $e');
      return false;
    }
  }

  // Check if any of the fee IDs in the list already have challans
  static Future<List<String>> getExistingChallanFeeIds(
    List<String> feeIds,
  ) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'challans',
        where:
            'reference_fee_id IN (${List.filled(feeIds.length, '?').join(',')})',
        whereArgs: feeIds,
      );

      // Extract fee IDs that already have challans
      return maps.map((map) => map['reference_fee_id'] as String).toList();
    } catch (e) {
      print('Error checking existing challan fee IDs: $e');
      return [];
    }
  }

  // Generate single entry challan
  static Future<bool> generateSingleChallan({
    required String studentId,
    String? classId,
    required String feesType,
    required double amount,
    String? referenceFeeId,
    String? month,
    String? examDetails,
    String? feeDetails,
    DateTime? datePaid,
    String? paymentMode,
    String? remarks,
  }) async {
    try {
      // Check if challan already exists for this fee (only if referenceFeeId is provided)
      if (referenceFeeId != null && referenceFeeId.isNotEmpty) {
        final exists = await challanExistsForFee(referenceFeeId);
        if (exists) {
          print('Challan already exists for fee ID: $referenceFeeId');
          return true; // Return true to avoid error, but don't create duplicate
        }
      }

      final challan = ChallanModel(
        studentId: studentId,
        classId: classId,
        feesType: feesType,
        amount: amount,
        referenceFeeId: referenceFeeId,
        month: month,
        examDetails: examDetails,
        feeDetails: feeDetails,
        datePaid: datePaid,
        paymentMode: paymentMode,
        remarks: remarks,
      );

      // Debug logging
      print('=== SINGLE CHALLAN GENERATION ===');
      print('Challan ID: ${challan.challanId}');
      print('Student ID: $studentId');
      print('Class ID: $classId');
      print('Fees Type: $feesType');
      print('Amount: $amount');
      print('Reference Fee ID: $referenceFeeId');
      print('Month: $month');
      print('Exam Details: $examDetails');
      print('Fee Details: $feeDetails');
      print('Date Paid: $datePaid');
      print('Payment Mode: $paymentMode');
      print('Remarks: $remarks');
      print('==================================');

      final success = await createChallan(challan);
      if (success) {
        print('Single challan generated successfully');
      }
      return success;
    } catch (e) {
      print('Error generating single challan: $e');
      return false;
    }
  }

  // Get count of unpaid fee entries for a student
  static Future<int> getUnpaidFeeEntriesCount(String studentId) async {
    try {
      final db = await DatabaseService.database;
      // For admission fees, we need to check aggregated payments
      // This is a simplified version - in real implementation, you'd need to
      // check across all fee types (admission, monthly, exam, misc)
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM paid_admission_fees
        WHERE student_id = ?
      ''',
        [studentId],
      );

      final count = result.first['count'] as int? ?? 0;
      print('Unpaid fee entries count for student $studentId: $count');
      return count;
    } catch (e) {
      print('Error getting unpaid fee entries count: $e');
      return 0;
    }
  }

  // Get unpaid fee entries for a student (simplified for admission fees)
  static Future<List<Map<String, dynamic>>> getUnpaidFeeEntries(
    String studentId,
  ) async {
    try {
      final db = await DatabaseService.database;
      // This is a simplified version for admission fees
      // In a full implementation, you'd aggregate from all fee tables
      final result = await db.rawQuery(
        '''
        SELECT
          student_id,
          SUM(amount_paid) as total_amount,
          MAX(payment_date) as latest_payment_date,
          COUNT(*) as payment_count,
          GROUP_CONCAT(mode_of_payment) as payment_modes
        FROM paid_admission_fees
        WHERE student_id = ?
        GROUP BY student_id
      ''',
        [studentId],
      );

      return result;
    } catch (e) {
      print('Error getting unpaid fee entries: $e');
      return [];
    }
  }

  // Generate separate individual challans for multiple entries
  static Future<bool> generateSeparateChallans({
    required String studentId,
    required String? classId,
    required List<Map<String, dynamic>> selectedEntries,
    String? remarks,
  }) async {
    try {
      print('=== GENERATING SEPARATE CHALLANS ===');
      print('Student ID: $studentId');
      print('Class ID: $classId');
      print('Selected Entries Count: ${selectedEntries.length}');
      print('=====================================');

      bool allSuccess = true;
      int successCount = 0;

      // Loop through each selected entry and create individual challans
      for (final entry in selectedEntries) {
        try {
          final entryId = entry['id']?.toString() ?? '';
          final amount = entry['amount'] as double? ?? 0.0;
          final paymentDate = entry['payment_date'] as DateTime?;
          final paymentMode = entry['mode_of_payment'] as String? ?? '';
          final feesType = entry['fees_type'] as String? ?? 'Admission';

          // Check if challan already exists for this entry
          final exists = await challanExistsForFee(entryId);
          if (exists) {
            print('⚠️ Skipping entry $entryId - challan already exists');
            continue;
          }

          // Get additional fee entry details from database
          String? month;
          String? examDetails;
          String? feeDetails;

          // For admission fees, we need to get the month from the payment date
          // For other fee types, we would need to query their respective tables
          if (feesType == 'Admission') {
            // For admission fees, use the payment month
            month = paymentDate != null
                ? DateFormat('MMMM - yyyy').format(paymentDate)
                : DateFormat('MMMM - yyyy').format(DateTime.now());
          } else if (feesType == 'Monthly') {
            // For monthly fees, we need to get the month from the monthly_fees table
            // For now, use payment month as fallback
            month = paymentDate != null
                ? DateFormat('MMMM - yyyy').format(paymentDate)
                : DateFormat('MMMM - yyyy').format(DateTime.now());
          } else if (feesType == 'Exam') {
            // For exam fees, we need to get exam details from exam_fees_pending table
            examDetails = entry['exam_details'] ?? 'Exam Fee';
            month = paymentDate != null
                ? DateFormat('MMMM - yyyy').format(paymentDate)
                : DateFormat('MMMM - yyyy').format(DateTime.now());
          } else if (feesType == 'Misc') {
            // For misc fees, we need to get fee details from misc_fees_pending table
            feeDetails = entry['fee_details'] ?? 'Miscellaneous Fee';
            month = paymentDate != null
                ? DateFormat('MMMM - yyyy').format(DateTime.now())
                : DateFormat('MMMM - yyyy').format(DateTime.now());
          }

          // Create individual challan for this entry
          final challan = ChallanModel(
            studentId: studentId,
            classId: classId,
            feesType: feesType,
            amount: amount,
            referenceFeeId: entryId,
            month: month,
            examDetails: examDetails,
            feeDetails: feeDetails,
            datePaid: paymentDate,
            paymentMode: paymentMode,
            remarks: remarks,
          );

          // Debug logging for each challan
          print('📄 Creating Challan:');
          print('  Challan ID: ${challan.challanId}');
          print('  Student ID: $studentId');
          print('  Reference Fee ID: $entryId');
          print('  Fees Type: $feesType');
          print('  Amount: $amount');
          print('  Month: $month');
          print('  Exam Details: $examDetails');
          print('  Fee Details: $feeDetails');
          print('  Payment Date: $paymentDate');
          print('  Payment Mode: $paymentMode');

          final success = await createChallan(challan);
          if (success) {
            successCount++;
            print('✅ Challan created successfully for entry $entryId');
          } else {
            print('❌ Failed to create challan for entry $entryId');
            allSuccess = false;
          }

          print('---');
        } catch (e) {
          print('❌ Error processing entry ${entry['id']}: $e');
          allSuccess = false;
        }
      }

      print('=== SEPARATE CHALLANS GENERATION COMPLETE ===');
      print('Total entries processed: ${selectedEntries.length}');
      print('Successful challans created: $successCount');
      print('All successful: $allSuccess');
      print('==============================================');

      return allSuccess && successCount > 0;
    } catch (e) {
      print('❌ Error generating separate challans: $e');
      return false;
    }
  }
}
