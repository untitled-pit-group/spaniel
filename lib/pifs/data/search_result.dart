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

  // TODO(gampixi): A global fromJson that will forward construction the correct typed result
}

/// The plain search result doesn't implement anything special, but it's
/// separated out for the sake of clarity.
class PifsPlainSearchResult extends PifsSearchResult {
  PifsPlainSearchResult({
    required String fileId,
    required String fragment,
    required List<PifsRange> ranges
  }) : super(fileId: fileId, fragment: fragment, ranges: ranges);

  // TODO(gampixi): fromJson
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

  // TODO(gampixi): fromJson
}

/// The document search result contains a field [page] which indicates in
/// which page of the document the excerpt can be found.
class PifsMediaSearchResult extends PifsSearchResult {
  // TODO(gampixi): I'm not sure what type to expect here, but a double seems like a safe bet
  final double durationInSeconds;

  late final Duration duration = Duration(seconds: durationInSeconds.round());

  PifsMediaSearchResult({
    required String fileId,
    required String fragment,
    required List<PifsRange> ranges,
    required this.durationInSeconds
  }) : super(fileId: fileId, fragment: fragment, ranges: ranges);

  // TODO(gampixi): fromJson
}