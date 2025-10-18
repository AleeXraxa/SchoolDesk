class DashboardStatsModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final int totalSubjects;
  final double attendanceRate;
  final int pendingTasks;

  DashboardStatsModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.totalSubjects,
    required this.attendanceRate,
    required this.pendingTasks,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      totalSubjects: json['totalSubjects'] ?? 0,
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
      pendingTasks: json['pendingTasks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalClasses': totalClasses,
      'totalSubjects': totalSubjects,
      'attendanceRate': attendanceRate,
      'pendingTasks': pendingTasks,
    };
  }
}
