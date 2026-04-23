import 'package:intl/intl.dart';

class DateFormatter {
  static String formatISO(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'Not set') {
      return 'Not set';
    }
    try {
      // Normalize input: if it's an ISO string, take the date part to prevent timezone shifts
      String normalized = dateStr;
      if (dateStr.contains('T')) {
        normalized = dateStr.split('T')[0];
      }

      // Handle YYYY-MM-DD
      if (normalized.length >= 10) {
        final parts = normalized.substring(0, 10).split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return DateFormat('MMM dd, yyyy').format(date);
        }
      }

      // Fallback for other formats
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  static String formatFull(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Not set';
    try {
      String normalized = dateStr;
      if (dateStr.contains('T')) {
        normalized = dateStr.split('T')[0];
      }
      if (normalized.length >= 10) {
        final parts = normalized.substring(0, 10).split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return DateFormat('EEE, MMM dd, yyyy').format(date);
        }
      }
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('EEE, MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
