class ClassModel {
  final int? id;
  final String className;
  final String section;
  final int totalStudents;

  ClassModel({
    this.id,
    required this.className,
    required this.section,
    this.totalStudents = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'section': section,
      'total_students': totalStudents,
    };
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int?,
      className: json['class_name'] ?? '',
      section: json['section'] ?? '',
      totalStudents: json['total_students'] ?? 0,
    );
  }

  String get displayName => '$className - $section';
}
