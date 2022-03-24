import "package:equatable/equatable.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:collection/collection.dart";

/// Holds state for the changes given to metadata of a [PifsFile],
/// allows for non-destructive editing until commit.
class PifsFileStagedMetadata with EquatableMixin {
  final String? name;
  final List<String>? tags;
  final DateTime? relevanceTimestamp;

  PifsFileStagedMetadata._internal({
    required this.name,
    required this.tags,
    required this.relevanceTimestamp
  });

  factory PifsFileStagedMetadata.initial(PifsFile? initial) {
    return PifsFileStagedMetadata._internal(
        name: initial?.name,
        tags: initial != null ? List.of(initial.tags) : null,
        relevanceTimestamp: initial?.relevanceTimestamp
    );
  }

  /// Checks if this staged metadata is dirty with respect to the given [PifsFile]
  bool isChanged(PifsFile file) {
    if(file.name != name) return true;
    if(file.relevanceTimestamp != relevanceTimestamp) return true;
    if(tags != null) {
      // Do a deep comparison of the list contents.
      // BUGBUG: A different order also means different tags! Is this ok?
      if(!file.tags.equals(tags!)) return true;
    }
    return false;
  }

  PifsFileStagedMetadata withName(String? name) {
    return PifsFileStagedMetadata._internal(
        name: name,
        tags: tags,
        relevanceTimestamp: relevanceTimestamp
    );
  }

  PifsFileStagedMetadata withTags(List<String>? tags) {
    return PifsFileStagedMetadata._internal(
        name: name,
        tags: tags,
        relevanceTimestamp: relevanceTimestamp
    );
  }

  PifsFileStagedMetadata withRelevanceTimestamp(DateTime? relevanceTimestamp) {
    return PifsFileStagedMetadata._internal(
        name: name,
        tags: tags,
        relevanceTimestamp: relevanceTimestamp
    );
  }

  @override List<Object?> get props => [name, tags, relevanceTimestamp];
}