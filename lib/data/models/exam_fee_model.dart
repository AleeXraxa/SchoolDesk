class ExamFeeModel {
  final int? id;
  final int studentId;
  final int classId;
  final String examName;
  final String examMonth;
  final double totalFee;
  final double paidAmount;
  final String status; // 'Pending', 'Partially Paid', 'Paid'
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? section;

  double get remainingAmount => totalFee - paidAmount;

  ExamFeeModel({
    this.id,
    required this.studentId,
    required this.classId,
    required this.examName,
    required this.examMonth,
    required this.totalFee,
    required this.paidAmount,
    required this.status,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.studentName,
    this.rollNo,
    this.className,
    this.section,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'exam_name': examName,
      'exam_month': examMonth,
      'total_fee': totalFee,
      'paid_amount': paidAmount,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ExamFeeModel.fromJson(Map<String, dynamic> json) {
    return ExamFeeModel(
      id: json['id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      examName: json['exam_name'],
      examMonth: json['exam_month'],
      totalFee: (json['total_fee'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      studentName: json['student_name'],
      rollNo: json['roll_no'],
      className: json['class_name'],
      section: json['section'],
    );
  }

  ExamFeeModel copyWith({
    int? id,
    int? studentId,
    int? classId,
    String? examName,
    String? examMonth,
    double? totalFee,
    double? paidAmount,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studentName,
    String? rollNo,
    String? className,
    String? section,
  }) {
    return ExamFeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      examName: examName ?? this.examName,
      examMonth: examMonth ?? this.examMonth,
      totalFee: totalFee ?? this.totalFee,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      className: className ?? this.className,
      section: section ?? this.section,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isPartiallyPaid => status == 'Partially Paid';
  bool get isPaid => status == 'Paid';
}
