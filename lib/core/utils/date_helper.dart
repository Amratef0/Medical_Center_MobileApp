import 'package:intl/intl.dart';

/// دوال بسيطة لتنسيق التواريخ في كل الابليكيشن.
class DateHelper {
  DateHelper._();

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy/MM/dd - hh:mm a').format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('hh:mm a').format(date);
  }

  /// بيحاول يحوّل أي نص تاريخ جاي من الـ API لـ DateTime، ولو فشل يرجع null
  /// بدل ما الابليكيشن يعمل كراش.
  static DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
