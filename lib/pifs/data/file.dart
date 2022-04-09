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
  final Set<String> tags;

  /// A timestamp at which the upload of the file was begun.
  final DateTime uploadTimestamp;

  /// A timestamp, as provided by the user.
  /// [null] if the relevance timestamp has not been set by the user.
  final DateTime? relevanceTimestamp;

  /// The size of the file in bytes.
  final int length;

  /// The SHA-256 hash of the file in hex form.
  final String hash;

  /// Either [document], [plain] or [media], depending on the document's specifics.
  /// This also determines the kind of search results returned.
  final PifsFileType type;

  final PifsIndexingState indexingState;

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
    required this.type,
    required this.indexingState,
  });

  // Equal IDs are enough to claim that two files are equal, right?
  @override List<Object?> get props => [id];

  factory PifsFile.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final j = Unjsoner(json);
      final indexingState = j.vt("indexing_state", PifsIndexingStateHelper.getFromInt);
      final type = j.vtOpt("type", PifsFileTypeHelper.getFromString) ?? PifsFileType.unknown;
      return PifsFile(
        id: j.v("id"),
        name: j.v("name"),
        tags: Set<String>.from(j.list("tags")),
        uploadTimestamp: j.vt("upload_timestamp", DateTime.tryParse),
        relevanceTimestamp: j.vtOpt("relevance_timestamp", DateTime.tryParse),
        length: j.v("length"),
        hash: j.v("hash"),
        type: type,
        indexingState: indexingState,
        removalDeadline: indexingState == PifsIndexingState.error ?
          j.vt("removal_deadline", DateTime.tryParse) : null,
      );
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}
