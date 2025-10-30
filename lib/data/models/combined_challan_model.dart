import 'dart:convert';

class CombinedChallanModel {
  final int? id;
  final int studentId;
  final String month;
  final double totalAmount;
  final List<Map<String, dynamic>> selectedFeesDetails;
  final DateTime generatedDate;
  final String status;
  final String? createdBy;

  // Joined data
  final String? studentName;
  final String? rollNo;

  CombinedChallanModel({
    this.id,
    required this.studentId,
    required this.month,
    required this.totalAmount,
    required this.selectedFeesDetails,
    DateTime? generatedDate,
    this.status = 'Pending',
    this.createdBy,
    this.studentName,
    this.rollNo,
  }) : generatedDate = generatedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'month': month,
      'total_amount': totalAmount,
      'selected_fees_details': jsonEncode(selectedFeesDetails),
      'generated_date': generatedDate.toIso8601String(),
      'status': status,
      'created_by': createdBy,
    };
  }

  factory CombinedChallanModel.fromJson(Map<String, dynamic> json) {
    return CombinedChallanModel(
      id: json['id'],
      studentId: json['student_id'],
      month: json['month'],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      selectedFeesDetails: json['selected_fees_details'] is String
          ? List<Map<String, dynamic>>.from(
              jsonDecode(json['selected_fees_details']),
            )
          : List<Map<String, dynamic>>.from(
              json['selected_fees_details'] ?? [],
            ),
      generatedDate: json['generated_date'] != null
          ? DateTime.parse(json['generated_date'])
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      createdBy: json['created_by'],
      studentName: json['student_name'],
      rollNo: json['roll_no'],
    );
  }

  factory CombinedChallanModel.fromMap(Map<String, dynamic> map) {
    return CombinedChallanModel(
      id: map['id'],
      studentId: map['student_id'],
      month: map['month'],
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      selectedFeesDetails: map['selected_fees_details'] is String
          ? List<Map<String, dynamic>>.from(
              jsonDecode(map['selected_fees_details']),
            )
          : List<Map<String, dynamic>>.from(map['selected_fees_details'] ?? []),
      generatedDate: map['generated_date'] != null
          ? DateTime.parse(map['generated_date'])
          : DateTime.now(),
      status: map['status'] ?? 'Pending',
      createdBy: map['created_by'],
      studentName: map['student_name'],
      rollNo: map['roll_no'],
    );
  }

  CombinedChallanModel copyWith({
    int? id,
    int? studentId,
    String? month,
    double? totalAmount,
    List<Map<String, dynamic>>? selectedFeesDetails,
    DateTime? generatedDate,
    String? status,
    String? createdBy,
    String? studentName,
    String? rollNo,
  }) {
    return CombinedChallanModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      selectedFeesDetails: selectedFeesDetails ?? this.selectedFeesDetails,
      generatedDate: generatedDate ?? this.generatedDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isPaid => status == 'Paid';

  // Helper method to get formatted fees breakdown
  String getFormattedFeesBreakdown() {
    final breakdown = selectedFeesDetails
        .map((fee) {
          final type = fee['type'] ?? 'Unknown';
          final amount = fee['amount'] ?? 0.0;
          final date = fee['date'] ?? '';
          return '$type: Rs. ${amount.toStringAsFixed(0)} ($date)';
        })
        .join('\n');

    return breakdown.isNotEmpty ? breakdown : 'No fee details available';
  }

  // Helper method to get fees summary by type
  Map<String, double> getFeesSummaryByType() {
    final summary = <String, double>{};
    for (final fee in selectedFeesDetails) {
      final type = fee['type'] as String? ?? 'Unknown';
      final amount = (fee['amount'] as num?)?.toDouble() ?? 0.0;
      summary[type] = (summary[type] ?? 0.0) + amount;
    }
    return summary;
  }
}
