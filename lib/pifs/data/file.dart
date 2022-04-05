import "package:equatable/equatable.dart";

import "src/file_type.dart";
import "src/indexing_state.dart";

export "src/file_type.dart";
export "src/indexing_state.dart";

import "package:spaniel/pifs/support/json.dart";

class PifsFile with EquatableMixin {
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

  /// The SHA-256 hash of the file in hex form.
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

  PifsFile({
    required this.id,
    required this.name,
    required this.tags,
    required this.uploadTimestamp,
    this.relevanceTimestamp,
    required this.length,
    required this.hash,
    this.removalDeadline,

    /// The document's type. This must be a value for which
    /// [PifsFileTypeHelper.isValid] returns [true].
    required String type,

    /// The indexing state of this file. This must be a value for which
    /// [PifsIndexingStateHelper.isValid] returns [true].
    required int indexingState,
  }) : _type = type, _indexingState = indexingState {
    if (!PifsFileTypeHelper.isValid(type)) {
      throw ArgumentError.value(type, "type");
    }
    if (!PifsIndexingStateHelper.isValid(indexingState)) {
      throw ArgumentError.value(indexingState, "indexingState");
    }
  }

  /// This constructor bypasses the validation checks for [type] and
  /// [indexingState] and so should be used with care.
  const PifsFile._({
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

  // Equal IDs are enough to claim that two files are equal, right?
  @override List<Object?> get props => [id];

  factory PifsFile.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final j = Unjsoner(json);
      final id = j.v<String>("id");
      final name = j.v<String>("name");
      final tags = j.list<String>("tags");
      final uploadTimestamp = j.vt("upload_timestamp", DateTime.tryParse);
      final relevanceTimestamp = j.vtOpt("relevance_timestamp", DateTime.tryParse);
      final length = j.v<int>("length");
      final hash = j.v<String>("hash");
      final type = j.val("type", PifsFileTypeHelper.isValid);
      final indexingState = j.val("indexing_state", PifsIndexingStateHelper.isValid);

      DateTime? removalDeadline;
      if (indexingState == PifsIndexingStateHelper.codeError) {
        removalDeadline = j.vt("removal_deadline", DateTime.tryParse);
      }

      return PifsFile._(
        id: id,
        name: name,
        tags: tags,
        uploadTimestamp: uploadTimestamp,
        relevanceTimestamp: relevanceTimestamp,
        length: length,
        hash: hash,
        removalDeadline: removalDeadline,
        type: type,
        indexingState: indexingState,
      );
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}
