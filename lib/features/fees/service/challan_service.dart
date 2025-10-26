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
}
