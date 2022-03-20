import "src/file_type.dart";
import "src/indexing_state.dart";

export "src/file_type.dart";
export "src/indexing_state.dart";

class PifsFile {
  /// The file ID.
  final String id;

  /// The file's literal name, as set during the upload.
  final String name;

  /// An array of string tags.
  final List<String> tags;

  /// A timestamp at which the upload of the file was begun.
  final DateTime uploadTimestamp;

  /// A timestamp, as provided by the user.
  /// [null] if the relevance timestamp has not been set by the user.
  final DateTime? relevanceTimestamp;

  /// The size of the file in bytes.
  final int length;

  /// The SHA-256 hash of the file.
  final String hash;

  final String _type;
  /// Either [document], [plain] or [media], depending on the document's specifics.
  /// This also determines the kind of search results returned.
  PifsFileType get type => PifsFileTypeHelper.getFromString(_type);

  final int _indexingState;
  PifsIndexingState get indexingState => PifsIndexingStateHelper.getFromInt(_indexingState);

  /// Only present if [indexingState] is [PifsIndexingState.error].
  /// A Timestamp after which the file will be removed from GCS and from the database,
  /// and after which the file ID will become invalid.
  final DateTime? removalDeadline;

  const PifsFile({
    required this.id,
    required this.name,
    required this.tags,
    required this.uploadTimestamp,
    this.relevanceTimestamp,
    required this.length,
    required this.hash,
    this.removalDeadline,
    required String type,
    required int indexingState
  }) : _type = type, _indexingState = indexingState;
}