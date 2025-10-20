class MonthlyPaymentHistoryModel {
  final int? id;
  final int monthlyFeeId;
  final double paidAmount;
  final DateTime paymentDate;
  final String paymentMode;
  final String? remarks;
  final DateTime? createdAt;

  // Joined data
  final String? studentName;
  final String? rollNo;
  final String? month;

  MonthlyPaymentHistoryModel({
    this.id,
    required this.monthlyFeeId,
    required this.paidAmount,
    required this.paymentDate,
    required this.paymentMode,
    this.remarks,
    this.createdAt,
    this.studentName,
    this.rollNo,
    this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthly_fee_id': monthlyFeeId,
      'paid_amount': paidAmount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_mode': paymentMode,
      'remarks': remarks,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory MonthlyPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return MonthlyPaymentHistoryModel(
      id: json['id'],
      monthlyFeeId: json['monthly_fee_id'],
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : DateTime.now(),
      paymentMode: json['payment_mode'] ?? '',
      remarks: json['remarks'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      studentName: json['student_name'],
      rollNo: json['roll_no'],
      month: json['month'],
    );
  }

  MonthlyPaymentHistoryModel copyWith({
    int? id,
    int? monthlyFeeId,
    double? paidAmount,
    DateTime? paymentDate,
    String? paymentMode,
    String? remarks,
    DateTime? createdAt,
    String? studentName,
    String? rollNo,
    String? month,
  }) {
    return MonthlyPaymentHistoryModel(
      id: id ?? this.id,
      monthlyFeeId: monthlyFeeId ?? this.monthlyFeeId,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      month: month ?? this.month,
    );
  }
}
