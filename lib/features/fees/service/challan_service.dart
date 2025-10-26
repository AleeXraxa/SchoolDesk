import '../../../data/database_service.dart';
import '../../../data/models/challan_model.dart';

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
      print('Challan created successfully: ${challan.challanId}');
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
      final List<Map<String, dynamic>> maps = await db.query(
        'challans',
        where: 'fees_type = ?',
        whereArgs: [feesType],
        orderBy: 'date_generated DESC',
      );

      return maps.map((map) => ChallanModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching challans by type: $e');
      return [];
    }
  }

  // Fetch all challans
  static Future<List<ChallanModel>> fetchAllChallans() async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'challans',
        orderBy: 'date_generated DESC',
      );

      return maps.map((map) => ChallanModel.fromMap(map)).toList();
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

      String whereClause = 'student_name LIKE ? OR roll_no LIKE ?';
      List<dynamic> whereArgs = ['%$query%', '%$query%'];

      if (feesType != null) {
        whereClause += ' AND fees_type = ?';
        whereArgs.add(feesType);
      }

      // Note: This assumes we have student data joined or available
      // In a real implementation, you might need to join with students table
      final List<Map<String, dynamic>> maps = await db.query(
        'challans',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date_generated DESC',
      );

      return maps.map((map) => ChallanModel.fromMap(map)).toList();
    } catch (e) {
      print('Error searching challans: $e');
      return [];
    }
  }
}
