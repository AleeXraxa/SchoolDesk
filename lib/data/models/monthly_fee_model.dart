class MonthlyFeeModel {
  final int? id;
  final int studentId;
  final String month;
  final double amount;
  final double paidAmount;
  final String status; // 'Pending', 'Partial', 'Paid'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? section;

  double get remainingAmount => amount - paidAmount;

  MonthlyFeeModel({
    this.id,
    required this.studentId,
    required this.month,
    required this.amount,
    required this.paidAmount,
    required this.status,
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
      'month': month,
      'amount': amount,
      'paid_amount': paidAmount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory MonthlyFeeModel.fromJson(Map<String, dynamic> json) {
    return MonthlyFeeModel(
      id: json['id'],
      studentId: json['student_id'],
      month: json['month'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
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

  MonthlyFeeModel copyWith({
    int? id,
    int? studentId,
    String? month,
    double? amount,
    double? paidAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studentName,
    String? rollNo,
    String? className,
    String? section,
  }) {
    return MonthlyFeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      className: className ?? this.className,
      section: section ?? this.section,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isPartial => status == 'Partial';
  bool get isPaid => status == 'Paid';
}
