class ExamPaidFeeModel {
  final int? id;
  final int? pendingExamFeeId;
  final int studentId;
  final int classId;
  final String examName;
  final double paidAmount;
  final DateTime paymentDate;
  final String paymentMode;
  final DateTime? createdAt;

  // Joined data
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? section;

  ExamPaidFeeModel({
    this.id,
    this.pendingExamFeeId,
    required this.studentId,
    required this.classId,
    required this.examName,
    required this.paidAmount,
    required this.paymentDate,
    required this.paymentMode,
    this.createdAt,
    this.studentName,
    this.rollNo,
    this.className,
    this.section,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pending_exam_fee_id': pendingExamFeeId,
      'student_id': studentId,
      'class_id': classId,
      'exam_name': examName,
      'paid_amount': paidAmount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_mode': paymentMode,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory ExamPaidFeeModel.fromJson(Map<String, dynamic> json) {
    return ExamPaidFeeModel(
      id: json['id'],
      pendingExamFeeId: json['pending_exam_fee_id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      examName: json['exam_name'],
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : DateTime.now(),
      paymentMode: json['payment_mode'] ?? 'Cash',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      studentName: json['student_name'],
      rollNo: json['roll_no'],
      className: json['class_name'],
      section: json['section'],
    );
  }

  ExamPaidFeeModel copyWith({
    int? id,
    int? pendingExamFeeId,
    int? studentId,
    int? classId,
    String? examName,
    double? paidAmount,
    DateTime? paymentDate,
    String? paymentMode,
    DateTime? createdAt,
    String? studentName,
    String? rollNo,
    String? className,
    String? section,
  }) {
    return ExamPaidFeeModel(
      id: id ?? this.id,
      pendingExamFeeId: pendingExamFeeId ?? this.pendingExamFeeId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      examName: examName ?? this.examName,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
      createdAt: createdAt ?? this.createdAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      className: className ?? this.className,
      section: section ?? this.section,
    );
  }
}
