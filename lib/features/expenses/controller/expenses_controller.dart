import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/expense_model.dart';
import '../service/expense_service.dart';

class ExpensesController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  RxString selectedPeriod = 'Monthly'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      final fetchedExpenses = await ExpenseService.getAllExpenses();
      expenses.value = fetchedExpenses;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load expenses: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      final id = await ExpenseService.addExpense(expense);
      final newExpense = expense.copyWith(id: id, createdAt: DateTime.now());
      expenses.insert(0, newExpense); // Add to top
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add expense: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      final success = await ExpenseService.updateExpense(expense);
      if (success) {
        final index = expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          expenses[index] = expense;
        }
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update expense: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      final success = await ExpenseService.deleteExpense(id);
      if (success) {
        expenses.removeWhere((e) => e.id == id);
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete expense: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  // Computed properties for summary
  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get monthlyExpenses {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get averageDaily {
    if (expenses.isEmpty) return 0.0;
    final dates = expenses.map((e) => e.date).toList();
    final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    final days = maxDate.difference(minDate).inDays + 1;
    return days > 0 ? totalExpenses / days : 0.0;
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  String get topCategory {
    if (categoryTotals.isEmpty) return 'None';
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double get topCategoryPercentage {
    if (totalExpenses == 0) return 0.0;
    return (categoryTotals[topCategory] ?? 0) / totalExpenses * 100;
  }

  List<Map<String, dynamic>> get categoryBreakdown {
    return categoryTotals.entries.map((entry) {
      final percentage = totalExpenses > 0
          ? (entry.value / totalExpenses * 100)
          : 0.0;
      return {
        'name': entry.key,
        'amount': entry.value,
        'percentage': percentage,
        'color': _getCategoryColor(entry.key),
      };
    }).toList()..sort(
      (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );
  }

  List<Map<String, dynamic>> get chartData {
    switch (selectedPeriod.value) {
      case 'Daily':
        return _getDailyData();
      case 'Weekly':
        return _getWeeklyData();
      case 'Monthly':
        return _getMonthlyData();
      case 'Yearly':
        return _getYearlyData();
      default:
        return _getMonthlyData();
    }
  }

  List<Map<String, dynamic>> _getDailyData() {
    final Map<String, double> dailyTotals = {};
    for (final expense in expenses) {
      final dayKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + expense.amount;
    }
    return dailyTotals.entries
        .map((e) => {'label': e.key.split('-').last, 'value': e.value})
        .toList()
      ..sort((a, b) => (a['label'] as String).compareTo(b['label'] as String));
  }

  List<Map<String, dynamic>> _getWeeklyData() {
    final Map<String, double> weeklyTotals = {};
    for (final expense in expenses) {
      final weekStart = expense.date.subtract(
        Duration(days: expense.date.weekday - 1),
      );
      final weekKey =
          '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      weeklyTotals[weekKey] = (weeklyTotals[weekKey] ?? 0) + expense.amount;
    }
    return weeklyTotals.entries
        .map((e) => {'label': 'Week of ${e.key}', 'value': e.value})
        .toList()
      ..sort((a, b) => (a['label'] as String).compareTo(b['label'] as String));
  }

  List<Map<String, dynamic>> _getMonthlyData() {
    final Map<String, double> monthlyTotals = {};
    for (final expense in expenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthlyTotals.entries.map((e) {
        final parts = e.key.split('-');
        final month = int.parse(parts[1]);
        return {'label': '${monthNames[month]} ${parts[0]}', 'value': e.value};
      }).toList()
      ..sort((a, b) => (a['label'] as String).compareTo(b['label'] as String));
  }

  List<Map<String, dynamic>> _getYearlyData() {
    final Map<int, double> yearlyTotals = {};
    for (final expense in expenses) {
      yearlyTotals[expense.date.year] =
          (yearlyTotals[expense.date.year] ?? 0) + expense.amount;
    }
    return yearlyTotals.entries
        .map((e) => {'label': e.key.toString(), 'value': e.value})
        .toList()
      ..sort((a, b) => (a['label'] as String).compareTo(b['label'] as String));
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salaries':
        return Colors.blue;
      case 'utilities':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'supplies':
        return Colors.red;
      case 'transportation':
        return Colors.purple;
      case 'marketing':
        return Colors.pink;
      case 'equipment':
        return Colors.teal;
      case 'rent':
        return Colors.brown;
      case 'insurance':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
