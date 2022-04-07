import 'package:spaniel/pifs/support/json.dart';

class PifsSearchPerformParameters implements Jsonable {
  final String query;

  PifsSearchPerformParameters({required this.query});

  @override dynamic toJson() {
    return {
      "search_query": query
    };
  }
}