class ChallanModel {
  final String challanId;
  final String studentId;
  final String? studentName; // Added student name field
  final String? rollNo; // Added roll number field
  final String? classId;
  final String feesType; // 'Admission', 'Monthly', 'Exam', 'Misc'
  final double amount;
  final String status; // 'Generated', 'Paid', 'Overdue', 'Cancelled'
  final DateTime dateGenerated;
  final String? referenceFeeId;
  final DateTime? datePaid;
  final String? paymentMode;
  final String? remarks;
  // Additional fields for specific fee types
  final String? month; // For Monthly fees (e.g., "October - 2025")
  final String? examDetails; // For Exam fees (e.g., "Annual Exam")
  final String? feeDetails; // For Misc fees (e.g., "Lab Maintenance")

  ChallanModel({
    String? challanId,
    required this.studentId,
    this.studentName,
    this.rollNo,
    this.classId,
    required this.feesType,
    required this.amount,
    this.status = 'Generated',
    DateTime? dateGenerated,
    this.referenceFeeId,
    this.datePaid,
    this.paymentMode,
    this.remarks,
    this.month,
    this.examDetails,
    this.feeDetails,
  }) : challanId = challanId ?? 'CH-${DateTime.now().millisecondsSinceEpoch}',
       dateGenerated = dateGenerated ?? DateTime.now();
  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'challan_id': challanId,
      'student_id': studentId,
      'class_id': classId,
      'fees_type': feesType,
      'amount': amount,
      'status': status,
      'date_generated': dateGenerated.toIso8601String(),
      'reference_fee_id': referenceFeeId,
      'date_paid': datePaid?.toIso8601String(),
      'payment_mode': paymentMode,
      'remarks': remarks,
      'month': month,
      'exam_details': examDetails,
      'fee_details': feeDetails,
    };
  }

  // Create from Map (database response)
  factory ChallanModel.fromMap(Map<String, dynamic> map) {
    return ChallanModel(
      challanId: map['challan_id'],
      studentId: map['student_id']?.toString() ?? '',
      studentName: map['student_name'], // Added student name from JOIN
      rollNo: map['roll_no'], // Added roll number from JOIN
      classId: map['class_id']?.toString(),
      feesType: map['fees_type'],
      amount: map['amount']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Generated',
      dateGenerated: DateTime.parse(map['date_generated']),
      referenceFeeId: map['reference_fee_id']?.toString(),
      datePaid: map['date_paid'] != null
          ? DateTime.parse(map['date_paid'])
          : null,
      paymentMode: map['payment_mode'],
      remarks: map['remarks'],
      month: map['month'],
      examDetails: map['exam_details'],
      feeDetails: map['fee_details'],
    );
  }

  // Copy with method for updates
  ChallanModel copyWith({
    String? challanId,
    String? studentId,
    String? studentName,
    String? rollNo,
    String? classId,
    String? feesType,
    double? amount,
    String? status,
    DateTime? dateGenerated,
    String? referenceFeeId,
    DateTime? datePaid,
    String? paymentMode,
    String? remarks,
    String? month,
    String? examDetails,
    String? feeDetails,
  }) {
    return ChallanModel(
      challanId: challanId ?? this.challanId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      classId: classId ?? this.classId,
      feesType: feesType ?? this.feesType,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      dateGenerated: dateGenerated ?? this.dateGenerated,
      referenceFeeId: referenceFeeId ?? this.referenceFeeId,
      datePaid: datePaid ?? this.datePaid,
      paymentMode: paymentMode ?? this.paymentMode,
      remarks: remarks ?? this.remarks,
      month: month ?? this.month,
      examDetails: examDetails ?? this.examDetails,
      feeDetails: feeDetails ?? this.feeDetails,
    );
  }

  @override
  String toString() {
    return 'ChallanModel(challanId: $challanId, studentId: $studentId, feesType: $feesType, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallanModel && other.challanId == challanId;
  }

  @override
  int get hashCode => challanId.hashCode;
}
