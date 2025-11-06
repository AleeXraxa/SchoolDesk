import '../../../data/database_service.dart';
import '../../../data/models/expense_model.dart';

class ExpenseService {
  static Future<int> addExpense(ExpenseModel expense) async {
    try {
      final db = await DatabaseService.database;
      final id = await db.insert('expenses', expense.toJson());
      return id;
    } catch (e, stackTrace) {
      print('ExpenseService: Error adding expense: $e');
      print('ExpenseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query('expenses', orderBy: 'created_at DESC');
      return result.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('ExpenseService: Error fetching expenses: $e');
      print('ExpenseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<ExpenseModel?> getExpenseById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return ExpenseModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('ExpenseService: Error fetching expense by ID: $e');
      print('ExpenseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      if (expense.id == null) return false;
      final db = await DatabaseService.database;
      final result = await db.update(
        'expenses',
        {...expense.toJson(), 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('ExpenseService: Error updating expense: $e');
      print('ExpenseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deleteExpense(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('ExpenseService: Error deleting expense: $e');
      print('ExpenseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<double> getTotalExpensesForCurrentMonth() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(
        now.year,
        now.month + 1,
        1,
      ).subtract(const Duration(days: 1));

      final db = await DatabaseService.database;
      final result = await db.query(
        'expenses',
        where: 'created_at >= ? AND created_at <= ?',
        whereArgs: [
          startOfMonth.toIso8601String(),
          endOfMonth.toIso8601String(),
        ],
      );

      final expenses = result
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
      double total = 0.0;
      for (var expense in expenses) {
        total += expense.amount;
      }
      return total;
    } catch (e, stackTrace) {
      print(
        'ExpenseService: Error getting total expenses for current month: $e',
      );
      print('ExpenseService: Stack trace: $stackTrace');
      return 0.0;
    }
  }
}
