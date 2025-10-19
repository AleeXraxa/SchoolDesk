class AdmissionFeeModel {
  final int? id;
  final int studentId;
  final double amountDue;
  final double amountPaid;
  final String status; // 'Pending' or 'Paid'
  final DateTime? dueDate;
  final DateTime? paymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final String? studentName;
  final String? rollNo;

  AdmissionFeeModel({
    this.id,
    required this.studentId,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    this.dueDate,
    this.paymentDate,
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
      'due_date': dueDate?.toIso8601String(),
      'payment_date': paymentDate?.toIso8601String(),
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
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
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
    DateTime? dueDate,
    DateTime? paymentDate,
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
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isPaid => status == 'Paid';
  double get remainingAmount => amountDue - amountPaid;
}
