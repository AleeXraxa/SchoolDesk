class MiscFeeModel {
  final int? id;
  final int studentId;
  final int classId;
  final String miscFeeType;
  final String month;
  final double totalFee;
  final double paidAmount;
  final String status; // 'Pending', 'Partially Paid', 'Paid'
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? description;

  // Joined data
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? section;

  double get remainingAmount => totalFee - paidAmount;

  MiscFeeModel({
    this.id,
    required this.studentId,
    required this.classId,
    required this.miscFeeType,
    required this.month,
    required this.totalFee,
    required this.paidAmount,
    required this.status,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.description,
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
      'misc_fee_type': miscFeeType,
      'month': month,
      'total_fee': totalFee,
      'paid_amount': paidAmount,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'description': description,
    };
  }

  factory MiscFeeModel.fromJson(Map<String, dynamic> json) {
    return MiscFeeModel(
      id: json['id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      miscFeeType: json['misc_fee_type'],
      month: json['month'],
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
      description: json['description'],
      studentName: json['student_name'],
      rollNo: json['roll_no'],
      className: json['class_name'],
      section: json['section'],
    );
  }

  MiscFeeModel copyWith({
    int? id,
    int? studentId,
    int? classId,
    String? miscFeeType,
    String? month,
    double? totalFee,
    double? paidAmount,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? studentName,
    String? rollNo,
    String? className,
    String? section,
  }) {
    return MiscFeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      miscFeeType: miscFeeType ?? this.miscFeeType,
      month: month ?? this.month,
      totalFee: totalFee ?? this.totalFee,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
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
