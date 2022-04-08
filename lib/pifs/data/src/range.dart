import 'package:spaniel/pifs/support/json.dart';

class PifsRange {
  final int start;
  final int end;

  PifsRange(this.start, this.end);

  factory PifsRange.fromJson(dynamic json) {
    if (json is List<dynamic> &&
        json.length == 2 &&
        json[0] is int && json[1] is int) {
      return PifsRange(json[0], json[1]);
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }

  static List<PifsRange> fromJsonList(List<dynamic> json) {
    return json.map((elem) => PifsRange.fromJson(elem)).toList(growable: false);
  }
}