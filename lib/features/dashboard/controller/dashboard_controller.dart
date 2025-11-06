import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../model/dashboard_stats_model.dart';
import '../service/dashboard_service.dart';
import '../../students/service/student_service.dart';
import '../../fees/service/monthly_payment_history_service.dart';
import '../../fees/service/monthly_fees_service.dart';
import '../../expenses/service/expense_service.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

  // User data
  var currentUser = Rx<UserModel?>(null);

  // Dashboard stats
  var dashboardStats = Rx<DashboardStatsModel?>(null);
  var isLoadingStats = false.obs;

  // Active students count
  var activeStudentsCount = 0.obs;

  // Total paid monthly fees
  var totalPaidMonthlyFees = 0.0.obs;

  // Monthly fees pending
  var monthlyFeesPending = 0.obs;

  // Count of fully paid monthly fees
  var countPaidMonthlyFees = 0.obs;

  // Admissions this month
  var admissionsThisMonth = 0.obs;

  // Total revenue this month
  var totalRevenueThisMonth = 0.0.obs;

  // Total expenses this month
  var totalExpensesThisMonth = 0.0.obs;

  // Monthly revenue overview state
  var selectedMonth = "November 2025".obs;
  var dailyRevenue = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Get user data from arguments or previous controller
    final args = Get.arguments;
    if (args != null && args is UserModel) {
      currentUser.value = args;
    }

    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    isLoadingStats.value = true;
    try {
      // Load active students count
      final students = await StudentService.getAllStudents();
      activeStudentsCount.value = students.length;

      // Load total paid monthly fees
      totalPaidMonthlyFees.value =
          await MonthlyPaymentHistoryService.getTotalPaidForCurrentMonth();

      // Load monthly fees pending
      monthlyFeesPending.value =
          await MonthlyFeesService.getMonthlyFeesPendingThisMonth();

      // Load count of fully paid monthly fees
      countPaidMonthlyFees.value =
          await MonthlyFeesService.getMonthlyFeesPaidThisMonth();

      // Load admissions this month
      admissionsThisMonth.value = await StudentService.getAdmissionsThisMonth();

      // Load total revenue (from all fee types)
      totalRevenueThisMonth.value =
          await MonthlyPaymentHistoryService.getTotalRevenue();

      // Load initial daily revenue for selected month
      await loadDailyRevenue();

      // Load total expenses for current month
      totalExpensesThisMonth.value =
          await ExpenseService.getTotalExpensesForCurrentMonth();

      // For demo purposes, create mock data
      await Future.delayed(const Duration(seconds: 1));
      dashboardStats.value = DashboardStatsModel(
        totalStudents: 1250,
        totalTeachers: 45,
        totalClasses: 32,
        totalSubjects: 18,
        attendanceRate: 87.5,
        pendingTasks: 12,
      );
    } catch (e) {
      print('Error loading dashboard stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  void logout() {
    Get.offAllNamed('/login');
  }

  Future<void> loadDailyRevenue() async {
    try {
      final parts = selectedMonth.value.split(' ');
      final monthName = parts[0];
      final year = int.parse(parts[1]);

      // Convert month name to number
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final month = monthNames.indexOf(monthName) + 1;

      final revenue =
          await MonthlyPaymentHistoryService.getDailyRevenueForMonth(
            year,
            month,
          );
      dailyRevenue.value = revenue;
    } catch (e) {
      print('Error loading daily revenue: $e');
      dailyRevenue.value = {};
    }
  }
}
