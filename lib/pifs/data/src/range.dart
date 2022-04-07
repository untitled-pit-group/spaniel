import 'package:spaniel/pifs/support/json.dart';

class PifsRange {
  final int start;
  final int end;

  PifsRange(this.start, this.end);

  factory PifsRange.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final j = Unjsoner(json);
      return PifsRange(j.v<int>("start"), j.v<int>("end"));
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}