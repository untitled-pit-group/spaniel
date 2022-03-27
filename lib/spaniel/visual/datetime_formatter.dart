import "package:intl/intl.dart";

abstract class SPDateTimeFormatter {
  String format(DateTime dateTime);
}

class SPReadableDateTimeFormatter implements SPDateTimeFormatter {
  static final formatter = DateFormat.yMMMd();

  @override
  String format(DateTime dateTime) {
    return formatter.format(dateTime);
  }
}