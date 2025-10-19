class AdmissionFeeModel {
  final int? id;
  final int studentId;
  final double amountDue;
  final double amountPaid;
  final String status; // 'Pending' or 'Paid'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final String? studentName;
  final String? rollNo;

  double get remainingAmount => amountDue - amountPaid;
  double get admissionFeeTotal => amountDue;

  AdmissionFeeModel({
    this.id,
    required this.studentId,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.studentName,
    this.rollNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'amount_due': amountDue,
      'amount_paid': amountPaid,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AdmissionFeeModel.fromJson(Map<String, dynamic> json) {
    return AdmissionFeeModel(
      id: json['id'],
      studentId: json['student_id'],
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      studentName: json['student_name'],
      rollNo: json['roll_no'],
    );
  }

  AdmissionFeeModel copyWith({
    int? id,
    int? studentId,
    double? amountDue,
    double? amountPaid,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studentName,
    String? rollNo,
  }) {
    return AdmissionFeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amountDue: amountDue ?? this.amountDue,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isPaid => status == 'Paid';
}
