import 'package:intl/intl.dart';

extension ToFoxhound on DateTime {
  String asFoxhoundString() {
    final definitelyUtc = toUtc();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');
    return "${dateFormat.format(definitelyUtc)}T${timeFormat.format(definitelyUtc)}Z";
  }
}