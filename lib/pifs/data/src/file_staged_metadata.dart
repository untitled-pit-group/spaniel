import 'package:dartz/dartz.dart';
import "package:equatable/equatable.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:collection/collection.dart";
import 'package:spaniel/pifs/parameters/files_edit.dart';
import 'package:spaniel/pifs/util/dartz.dart';

/// Holds state for the changes given to metadata of a [PifsFile],
/// allows for non-destructive editing until commit.
/// 
/// If an [Option] is a [None], that implies that no changes are yet staged.
/// Notably for [relevanceTimestamp], a [None] is different than [Some(null)],
/// where the latter implies that the date was cleared.
class PifsFileStagedMetadata with EquatableMixin {
  final Option<String> name;
  final Option<List<String>> tags;
  final Option<DateTime?> relevanceTimestamp;

  PifsFileStagedMetadata._(this.name, this.tags, this.relevanceTimestamp);
  PifsFileStagedMetadata.blank() :
    name = const None(), tags = const None(), relevanceTimestamp = const None();

  /// Checks if this staged metadata is dirty with respect to the given [PifsFile]
  bool isChanged(PifsFile file) {
    if (name is Some && name.unwrapped != file.name) return true;
    if (tags is Some) {
      // Do a deep comparison of the list contents.
      // BUGBUG: A different order also means different tags! Is this ok?
      if(!file.tags.equals(tags.unwrapped)) return true;
    }
    if (relevanceTimestamp is Some &&
        relevanceTimestamp.unwrapped != file.relevanceTimestamp) {
      return true;
    }
    return false;
  }

  PifsFileStagedMetadata withName(String name) =>
    PifsFileStagedMetadata._(Some(name), tags, relevanceTimestamp);
  PifsFileStagedMetadata withoutName() =>
    PifsFileStagedMetadata._(const None(), tags, relevanceTimestamp);
  PifsFileStagedMetadata withTags(List<String> tags) =>
    PifsFileStagedMetadata._(name, Some(tags), relevanceTimestamp);
  PifsFileStagedMetadata withoutTags() =>
    PifsFileStagedMetadata._(name, const None(), relevanceTimestamp);
  PifsFileStagedMetadata withRelevanceTimestamp(DateTime timestamp) =>
    PifsFileStagedMetadata._(name, tags, Some(timestamp));
  PifsFileStagedMetadata withWipedRelevanceTimestamp() =>
    PifsFileStagedMetadata._(name, tags, const Some(null));
  PifsFileStagedMetadata withoutRelevanceTimestamp() =>
    PifsFileStagedMetadata._(name, tags, const None());

  @override List<Object?> get props => [name, tags, relevanceTimestamp];
}