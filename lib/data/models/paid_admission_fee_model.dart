class PaidAdmissionFeeModel {
  final int? id;
  final int studentId;
  final double amountPaid;
  final DateTime paymentDate;
  final String modeOfPayment;
  final DateTime createdAt;

  // Joined data
  final String? studentName;
  final String? rollNo;
  final DateTime? admissionDate;

  PaidAdmissionFeeModel({
    this.id,
    required this.studentId,
    required this.amountPaid,
    required this.paymentDate,
    required this.modeOfPayment,
    DateTime? createdAt,
    this.studentName,
    this.rollNo,
    this.admissionDate,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'amount_paid': amountPaid,
      'payment_date': paymentDate.toIso8601String(),
      'mode_of_payment': modeOfPayment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PaidAdmissionFeeModel.fromJson(Map<String, dynamic> json) {
    return PaidAdmissionFeeModel(
      id: json['id'],
      studentId: json['student_id'],
      amountPaid: json['amount_paid'].toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      modeOfPayment: json['mode_of_payment'],
      createdAt: DateTime.parse(json['created_at']),
      studentName: json['student_name'],
      rollNo: json['roll_no'],
      admissionDate: json['admission_date'] != null
          ? DateTime.parse(json['admission_date'])
          : null,
    );
  }

  PaidAdmissionFeeModel copyWith({
    int? id,
    int? studentId,
    double? amountPaid,
    DateTime? paymentDate,
    String? modeOfPayment,
    DateTime? createdAt,
    String? studentName,
    String? rollNo,
    DateTime? admissionDate,
  }) {
    return PaidAdmissionFeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      modeOfPayment: modeOfPayment ?? this.modeOfPayment,
      createdAt: createdAt ?? this.createdAt,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      admissionDate: admissionDate ?? this.admissionDate,
    );
  }
}
