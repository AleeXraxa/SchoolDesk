import '../model/dashboard_stats_model.dart';

class DashboardService {
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      // In a real app, this would query the database for actual stats
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));

      return DashboardStatsModel(
        totalStudents: 1250,
        totalTeachers: 45,
        totalClasses: 32,
        totalSubjects: 18,
        attendanceRate: 87.5,
        pendingTasks: 12,
      );
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      // Mock recent activities
      await Future.delayed(const Duration(milliseconds: 500));

      return [
        {
          'id': 1,
          'type': 'student_enrolled',
          'message': 'New student John Doe enrolled in Class 10A',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'id': 2,
          'type': 'attendance_marked',
          'message': 'Attendance marked for Class 9B',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        },
        {
          'id': 3,
          'type': 'exam_scheduled',
          'message': 'Mathematics exam scheduled for next week',
          'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        },
        {
          'id': 4,
          'type': 'teacher_added',
          'message': 'New teacher Sarah Johnson joined the faculty',
          'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
        },
      ];
    } catch (e) {
      print('Error fetching recent activities: $e');
      return [];
    }
  }
}
