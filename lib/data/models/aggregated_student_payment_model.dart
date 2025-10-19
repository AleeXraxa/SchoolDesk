import 'package:bms/data/models/paid_admission_fee_model.dart';

class AggregatedStudentPaymentModel {
  final int studentId;
  final String? studentName;
  final String? rollNo;
  final DateTime? admissionDate;
  final double totalPaidAmount;
  final DateTime mostRecentPaymentDate;
  final int paymentCount;
  final List<PaidAdmissionFeeModel> individualPayments;

  AggregatedStudentPaymentModel({
    required this.studentId,
    this.studentName,
    this.rollNo,
    this.admissionDate,
    required this.totalPaidAmount,
    required this.mostRecentPaymentDate,
    required this.paymentCount,
    required this.individualPayments,
  });

  factory AggregatedStudentPaymentModel.fromPayments(
    List<PaidAdmissionFeeModel> payments,
  ) {
    if (payments.isEmpty) {
      throw ArgumentError('Payments list cannot be empty');
    }

    final firstPayment = payments.first;
    final studentId = firstPayment.studentId;
    final studentName = firstPayment.studentName;
    final rollNo = firstPayment.rollNo;
    final admissionDate = firstPayment.admissionDate;

    // Calculate totals
    final totalPaidAmount = payments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amountPaid,
    );

    // Find most recent payment date
    final mostRecentPaymentDate = payments
        .map((p) => p.paymentDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return AggregatedStudentPaymentModel(
      studentId: studentId,
      studentName: studentName,
      rollNo: rollNo,
      admissionDate: admissionDate,
      totalPaidAmount: totalPaidAmount,
      mostRecentPaymentDate: mostRecentPaymentDate,
      paymentCount: payments.length,
      individualPayments: payments,
    );
  }
}
