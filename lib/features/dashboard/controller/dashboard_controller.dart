import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../model/dashboard_stats_model.dart';
import '../service/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

  // User data
  var currentUser = Rx<UserModel?>(null);

  // Dashboard stats
  var dashboardStats = Rx<DashboardStatsModel?>(null);
  var isLoadingStats = false.obs;

  // Quick actions
  var selectedMenuIndex = 0.obs;

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

  void selectMenuItem(int index) {
    selectedMenuIndex.value = index;
  }

  void logout() {
    Get.offAllNamed('/login');
  }

  // Menu items for navigation
  List<Map<String, dynamic>> get menuItems => [
    {'icon': 'dashboard', 'title': 'Dashboard', 'route': '/dashboard'},
    {'icon': 'students', 'title': 'Students', 'route': '/students'},
    {'icon': 'teachers', 'title': 'Teachers', 'route': '/teachers'},
    {'icon': 'classes', 'title': 'Classes', 'route': '/classes'},
    {'icon': 'subjects', 'title': 'Subjects', 'route': '/subjects'},
    {'icon': 'reports', 'title': 'Reports', 'route': '/reports'},
    {'icon': 'settings', 'title': 'Settings', 'route': '/settings'},
  ];
}
