import '../../../data/database_service.dart';
import '../../../data/models/combined_challan_model.dart';
import 'dart:convert';

class CombinedChallanService {
  static final CombinedChallanService _instance =
      CombinedChallanService._internal();
  factory CombinedChallanService() => _instance;
  CombinedChallanService._internal();

  // Create a new combined challan
  static Future<bool> createCombinedChallan(
    CombinedChallanModel challan,
  ) async {
    try {
      final db = await DatabaseService.database;

      // Validate required fields
      if (challan.studentId <= 0 ||
          challan.month.isEmpty ||
          challan.totalAmount <= 0 ||
          challan.selectedFeesDetails.isEmpty) {
        print('Error: Invalid combined challan data');
        return false;
      }

      // Prepare data map
      final data = {
        'student_id': challan.studentId,
        'month': challan.month,
        'total_amount': challan.totalAmount,
        'selected_fees_details': jsonEncode(challan.selectedFeesDetails),
        'generated_date': challan.generatedDate.toIso8601String(),
        'status': challan.status,
        'created_by': challan.createdBy,
      };

      final result = await db.insert('multiple_challans', data);

      if (result > 0) {
        print('🧾 Combined challan created successfully:');
        print('  ID: $result');
        print('  Student ID: ${challan.studentId}');
        print('  Month: ${challan.month}');
        print('  Total Amount: ${challan.totalAmount}');
        print('  Status: ${challan.status}');
        print('----------------------------');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      print('Error creating combined challan: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Fetch all combined challans
  static Future<List<CombinedChallanModel>> fetchAllCombinedChallans() async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT mc.*, s.student_name, s.roll_no
        FROM multiple_challans mc
        LEFT JOIN students s ON mc.student_id = s.id
        ORDER BY mc.generated_date DESC
      ''');

      final challans = maps
          .map((map) => CombinedChallanModel.fromMap(map))
          .toList();
      print('Fetched ${challans.length} combined challans');
      return challans;
    } catch (e) {
      print('Error fetching combined challans: $e');
      return [];
    }
  }

  // Fetch combined challans by student ID
  static Future<List<CombinedChallanModel>> fetchCombinedChallansByStudent(
    int studentId,
  ) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT mc.*, s.student_name, s.roll_no
        FROM multiple_challans mc
        LEFT JOIN students s ON mc.student_id = s.id
        WHERE mc.student_id = ?
        ORDER BY mc.generated_date DESC
      ''',
        [studentId],
      );

      final challans = maps
          .map((map) => CombinedChallanModel.fromMap(map))
          .toList();
      print(
        'Fetched ${challans.length} combined challans for student $studentId',
      );
      return challans;
    } catch (e) {
      print('Error fetching combined challans by student: $e');
      return [];
    }
  }

  // Fetch combined challans by month
  static Future<List<CombinedChallanModel>> fetchCombinedChallansByMonth(
    String month,
  ) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT mc.*, s.student_name, s.roll_no
        FROM multiple_challans mc
        LEFT JOIN students s ON mc.student_id = s.id
        WHERE mc.month = ?
        ORDER BY mc.generated_date DESC
      ''',
        [month],
      );

      final challans = maps
          .map((map) => CombinedChallanModel.fromMap(map))
          .toList();
      print('Fetched ${challans.length} combined challans for month $month');
      return challans;
    } catch (e) {
      print('Error fetching combined challans by month: $e');
      return [];
    }
  }

  // Get combined challan by ID
  static Future<CombinedChallanModel?> getCombinedChallanById(int id) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT mc.*, s.student_name, s.roll_no
        FROM multiple_challans mc
        LEFT JOIN students s ON mc.student_id = s.id
        WHERE mc.id = ?
        LIMIT 1
      ''',
        [id],
      );

      if (maps.isNotEmpty) {
        return CombinedChallanModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting combined challan by ID: $e');
      return null;
    }
  }

  // Update combined challan status
  static Future<bool> updateCombinedChallanStatus(int id, String status) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.update(
        'multiple_challans',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      print('Error updating combined challan status: $e');
      return false;
    }
  }

  // Delete combined challan
  static Future<bool> deleteCombinedChallan(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'multiple_challans',
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      print('Error deleting combined challan: $e');
      return false;
    }
  }

  // Search combined challans by student name or roll number
  static Future<List<CombinedChallanModel>> searchCombinedChallans(
    String query,
  ) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT mc.*, s.student_name, s.roll_no
        FROM multiple_challans mc
        LEFT JOIN students s ON mc.student_id = s.id
        WHERE s.student_name LIKE ? OR s.roll_no LIKE ?
        ORDER BY mc.generated_date DESC
      ''',
        ['%$query%', '%$query%'],
      );

      final challans = maps
          .map((map) => CombinedChallanModel.fromMap(map))
          .toList();
      print(
        'Searched combined challans: ${challans.length} items found for query: $query',
      );
      return challans;
    } catch (e) {
      print('Error searching combined challans: $e');
      return [];
    }
  }

  // Check if combined challan exists for student and month
  static Future<bool> combinedChallanExists(int studentId, String month) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'multiple_challans',
        where: 'student_id = ? AND month = ?',
        whereArgs: [studentId, month],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking combined challan existence: $e');
      return false;
    }
  }

  // Generate combined challan from selected entries
  static Future<bool> generateCombinedChallan({
    required int studentId,
    required String month,
    required List<Map<String, dynamic>> selectedEntries,
    String? createdBy,
  }) async {
    try {
      // Check if combined challan already exists
      final exists = await combinedChallanExists(studentId, month);
      if (exists) {
        print(
          'Combined challan already exists for student $studentId in month $month',
        );
        return false;
      }

      // Calculate total amount
      final totalAmount = selectedEntries.fold<double>(
        0.0,
        (sum, entry) => sum + ((entry['amount'] as num?)?.toDouble() ?? 0.0),
      );

      if (totalAmount <= 0) {
        print('Error: Total amount must be greater than 0');
        return false;
      }

      // Prepare fees details
      final feesDetails = selectedEntries.map((entry) {
        return {
          'type': entry['fees_type'] ?? 'Unknown',
          'amount': (entry['amount'] as num?)?.toDouble() ?? 0.0,
          'date': entry['payment_date'] != null
              ? (entry['payment_date'] is DateTime
                    ? (entry['payment_date'] as DateTime).toIso8601String()
                    : entry['payment_date'].toString())
              : DateTime.now().toIso8601String(),
        };
      }).toList();

      // Create combined challan
      final combinedChallan = CombinedChallanModel(
        studentId: studentId,
        month: month,
        totalAmount: totalAmount,
        selectedFeesDetails: feesDetails,
        status: 'Pending',
        createdBy: createdBy,
      );

      print('=== COMBINED CHALLAN GENERATION ===');
      print('Student ID: $studentId');
      print('Month: $month');
      print('Total Amount: $totalAmount');
      print('Selected Entries: ${selectedEntries.length}');
      print('Fees Details: ${jsonEncode(feesDetails)}');
      print('=====================================');

      final success = await createCombinedChallan(combinedChallan);
      if (success) {
        print('Combined challan generated successfully');
      }
      return success;
    } catch (e) {
      print('Error generating combined challan: $e');
      return false;
    }
  }
}
