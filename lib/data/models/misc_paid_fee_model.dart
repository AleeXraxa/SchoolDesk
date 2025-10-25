class MiscPaidFeeModel {
  final int? id;
  final int? pendingMiscFeeId;
  final int studentId;
  final int classId;
  final String miscFeeType;
  final double paidAmount;
  final DateTime paymentDate;
  final String paymentMode;
  final DateTime? createdAt;

  // Joined data
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? section;

  // Additional fields for aggregated view
  final double? totalFee;
  final double? remainingAmount;

  MiscPaidFeeModel({
    this.id,
    this.pendingMiscFeeId,
    required this.studentId,
    required this.classId,
    required this.miscFeeType,
    required this.paidAmount,
    required this.paymentDate,
    required this.paymentMode,
    this.createdAt,
    this.studentName,
    this.rollNo,
    this.className,
    this.section,
    this.totalFee,
    this.remainingAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pending_misc_fee_id': pendingMiscFeeId,
      'student_id': studentId,
      'class_id': classId,
      'misc_fee_type': miscFeeType,
      'paid_amount': paidAmount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_mode': paymentMode,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory MiscPaidFeeModel.fromJson(Map<String, dynamic> json) {
    return MiscPaidFeeModel(
      id: json['id'],
      pendingMiscFeeId: json['pending_misc_fee_id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      miscFeeType: json['misc_fee_type'],
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

  MiscPaidFeeModel copyWith({
    int? id,
    int? pendingMiscFeeId,
    int? studentId,
    int? classId,
    String? miscFeeType,
    double? paidAmount,
    DateTime? paymentDate,
    String? paymentMode,
    DateTime? createdAt,
    String? studentName,
    String? rollNo,
    String? className,
    String? section,
    double? totalFee,
    double? remainingAmount,
  }) {
    return MiscPaidFeeModel(
      id: id ?? this.id,
      pendingMiscFeeId: pendingMiscFeeId ?? this.pendingMiscFeeId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      miscFeeType: miscFeeType ?? this.miscFeeType,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
      createdAt: createdAt ?? this.createdAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      className: className ?? this.className,
      section: section ?? this.section,
      totalFee: totalFee ?? this.totalFee,
      remainingAmount: remainingAmount ?? this.remainingAmount,
    );
  }
}
