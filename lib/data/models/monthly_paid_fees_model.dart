import 'package:bms/data/models/monthly_payment_history_model.dart';

class MonthlyPaidFeesModel {
  final int studentId;
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? section;
  final String month;
  final double totalPaidAmount;
  final double totalFeeAmount;
  final DateTime mostRecentPaymentDate;
  final int paymentCount;
  final List<MonthlyPaymentHistoryModel> individualPayments;

  MonthlyPaidFeesModel({
    required this.studentId,
    this.studentName,
    this.rollNo,
    this.className,
    this.section,
    required this.month,
    required this.totalPaidAmount,
    required this.totalFeeAmount,
    required this.mostRecentPaymentDate,
    required this.paymentCount,
    required this.individualPayments,
  });

  factory MonthlyPaidFeesModel.fromPayments(
    List<MonthlyPaymentHistoryModel> payments,
  ) {
    if (payments.isEmpty) {
      throw ArgumentError('Payments list cannot be empty');
    }

    final firstPayment = payments.first;
    final studentId =
        firstPayment.monthlyFeeId; // Use monthlyFeeId as studentId for grouping
    final studentName = firstPayment.studentName;
    final rollNo = firstPayment.rollNo;
    final month = firstPayment.month ?? 'Unknown';

    // Calculate totals
    final totalPaidAmount = payments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.paidAmount,
    );

    // Find most recent payment date
    final mostRecentPaymentDate = payments
        .map((p) => p.paymentDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return MonthlyPaidFeesModel(
      studentId: studentId,
      studentName: studentName,
      rollNo: rollNo,
      className: null, // Will be set from fee data
      section: null, // Will be set from fee data
      month: month,
      totalPaidAmount: totalPaidAmount,
      totalFeeAmount: 0.0, // Will be set from fee data
      mostRecentPaymentDate: mostRecentPaymentDate,
      paymentCount: payments.length,
      individualPayments: payments,
    );
  }

  String get formattedLastPaymentDate {
    return '${mostRecentPaymentDate.day}/${mostRecentPaymentDate.month}/${mostRecentPaymentDate.year}';
  }

  String get formattedTotalPaid {
    return 'PKR ${totalPaidAmount.toStringAsFixed(0)}';
  }

  double get remainingAmount => totalFeeAmount - totalPaidAmount;
}
