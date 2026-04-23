import 'payment.dart';

class HostelPaymentSummary {
  final PaymentStatusCounts counts;
  final PaymentStatusAmounts amounts;
  final List<Payment> overdue;
  final List<Payment> dueToday;
  final List<Payment> upcoming;
  final List<Payment> partialPayments;

  const HostelPaymentSummary({
    required this.counts,
    required this.amounts,
    required this.overdue,
    required this.dueToday,
    required this.upcoming,
    required this.partialPayments,
  });
}

class PaymentStatusCounts {
  final int overdue;
  final int dueToday;
  final int upcoming;
  final int partialPayments;

  const PaymentStatusCounts({
    required this.overdue,
    required this.dueToday,
    required this.upcoming,
    required this.partialPayments,
  });
}

class PaymentStatusAmounts {
  final double overdue;
  final double dueToday;
  final double upcoming;

  const PaymentStatusAmounts({
    required this.overdue,
    required this.dueToday,
    required this.upcoming,
  });
}
