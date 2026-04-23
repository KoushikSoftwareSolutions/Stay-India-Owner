import '../../domain/entities/hostel_payment_summary.dart';
import 'payment_model.dart';

class HostelPaymentSummaryModel extends HostelPaymentSummary {
  const HostelPaymentSummaryModel({
    required super.counts,
    required super.amounts,
    required super.overdue,
    required super.dueToday,
    required super.upcoming,
    required super.partialPayments,
  });

  factory HostelPaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final amounts = json['amounts'] as Map<String, dynamic>? ?? {};

    return HostelPaymentSummaryModel(
      counts: PaymentStatusCounts(
        overdue: (summary['overdue'] as num?)?.toInt() ?? 0,
        dueToday: (summary['dueToday'] as num?)?.toInt() ?? 0,
        upcoming: (summary['upcoming'] as num?)?.toInt() ?? 0,
        partialPayments: (summary['partialPayments'] as num?)?.toInt() ?? 0,
      ),
      amounts: PaymentStatusAmounts(
        overdue: (amounts['overdue'] as num?)?.toDouble() ?? 0.0,
        dueToday: (amounts['dueToday'] as num?)?.toDouble() ?? 0.0,
        upcoming: (amounts['upcoming'] as num?)?.toDouble() ?? 0.0,
      ),
      overdue: (json['overdue'] as List<dynamic>? ?? [])
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dueToday: (json['dueToday'] as List<dynamic>? ?? [])
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcoming: (json['upcoming'] as List<dynamic>? ?? [])
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      partialPayments: (json['partialPayments'] as List<dynamic>? ?? [])
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
