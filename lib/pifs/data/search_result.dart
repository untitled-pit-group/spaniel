import 'package:spaniel/pifs/support/json.dart';
import 'src/range.dart';

/// The base for all Pifs search results. Currently we expect all results
/// to contain the file ID, a text fragment and a set of [PifsRange] that
/// point inside the text fragment.
abstract class PifsSearchResult {
  final String fileId;
  final String fragment;
  final List<PifsRange> ranges;

  PifsSearchResult({
    required this.fileId,
    required this.fragment,
    required this.ranges
  });

  factory PifsSearchResult.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      Map<String, dynamic> _json = json;
      final j = Unjsoner(_json);
      String fileId = j.v("i");
      String fragment = j.v("f");
      List<PifsRange> ranges = PifsRange.fromJsonList(_json["r"]);
      if (_json.containsKey("p")) {
        int page = j.v("p");
        return PifsDocumentSearchResult(
          fileId: fileId,
          fragment: fragment,
          ranges: ranges,
          page: page,
        );
      } else if (_json.containsKey("t")) {
        double durationInSeconds = j.v("t");
        int seconds = durationInSeconds.floor();
        double microseconds = (durationInSeconds - seconds) * Duration.microsecondsPerSecond;
        Duration duration = Duration(
          seconds: seconds.floor(),
          microseconds: microseconds.floor(),
        );
        return PifsMediaSearchResult(
          fileId: fileId,
          fragment: fragment,
          ranges: ranges,
          duration: duration,
        );
      } else {
        return PifsPlainSearchResult(
          fileId: fileId,
          fragment: fragment,
          ranges: ranges,
        );
      }
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}

/// The plain search result doesn't implement anything special, but it's
/// separated out for the sake of clarity.
class PifsPlainSearchResult extends PifsSearchResult {
  PifsPlainSearchResult({
    required String fileId,
    required String fragment,
    required List<PifsRange> ranges
  }) : super(fileId: fileId, fragment: fragment, ranges: ranges);
}

/// The document search result contains a field [page] which indicates in
/// which page of the document the excerpt can be found.
class PifsDocumentSearchResult extends PifsSearchResult {
  final int page;

  PifsDocumentSearchResult({
    required String fileId,
    required String fragment,
    required List<PifsRange> ranges,
    required this.page
  }) : super(fileId: fileId, fragment: fragment, ranges: ranges);
}

/// The media search result contains a [duration], relative to the start of the
/// file, at which the excerpt can be found.
class PifsMediaSearchResult extends PifsSearchResult {
  final Duration duration;

  PifsMediaSearchResult({
    required String fileId,
    required String fragment,
    required List<PifsRange> ranges,
    required this.duration,
  }) : super(fileId: fileId, fragment: fragment, ranges: ranges);
}