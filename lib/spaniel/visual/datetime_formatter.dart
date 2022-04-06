import "package:intl/intl.dart";

abstract class SPDateTimeFormatter {
  String format(DateTime dateTime);
}

class SPReadableDateTimeFormatter implements SPDateTimeFormatter {
  static final formatter = DateFormat.yMMMd();

  const SPReadableDateTimeFormatter();

  @override
  String format(DateTime? dateTime) {
    return dateTime != null ? formatter.format(dateTime) : "—";
  }
}