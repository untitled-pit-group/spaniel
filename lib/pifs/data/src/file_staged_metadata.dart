import 'package:dartz/dartz.dart';
import "package:equatable/equatable.dart";
import "package:spaniel/pifs/data/file.dart";

typedef _PFSM = PifsFileStagedMetadata;
/// Holds state for the changes given to metadata of a [PifsFile],
/// allows for non-destructive editing until commit.
/// 
/// If an [Option] is a [Some], it implies that the given metadata item has been
/// edited; if it's a [None], it retains the value of the original file.
class PifsFileStagedMetadata with EquatableMixin {
  final Option<String> name;
  final Option<Set<String>> tags;

  /// A [Some(null)] implies that the relevance timestamp should explicitly be
  /// unset.
  final Option<DateTime?> relevanceTimestamp;

  const PifsFileStagedMetadata._internal({
    required this.name,
    required this.tags,
    required this.relevanceTimestamp,
  });
  const PifsFileStagedMetadata.blank() :
    name = const None(), tags = const None(),
    relevanceTimestamp = const None();

  /// Checks if this staged metadata is dirty with respect to the given [PifsFile]
  bool isChanged(PifsFile file) {
    if (name is Some && (name as Some).value != file.name) return true;
    if (relevanceTimestamp is Some &&
        (relevanceTimestamp as Some).value != file.name) return true;
    if (tags is Some && (tags as Some).value != file.tags) return true;
    return false;
  }

  _PFSM withName(String name) => _PFSM._internal(
    name: Some(name), tags: tags, relevanceTimestamp: relevanceTimestamp);
  _PFSM withoutName() => PifsFileStagedMetadata._internal(
    name: const None(), tags: tags, relevanceTimestamp: relevanceTimestamp);
  _PFSM withTags(Set<String> tags) => _PFSM._internal(
    name: name, tags: Some(tags), relevanceTimestamp: relevanceTimestamp);
  _PFSM withoutTags() => _PFSM._internal(
    name: name, tags: const None(), relevanceTimestamp: relevanceTimestamp);
  _PFSM withRelevanceTimestamp(DateTime? relevanceTimestamp) => _PFSM._internal(
    name: name, tags: tags, relevanceTimestamp: Some(relevanceTimestamp));
  _PFSM withoutRelevanceTimestamp() => _PFSM._internal(
    name: name, tags: tags, relevanceTimestamp: const None());

  @override List<Object?> get props => [name, tags, relevanceTimestamp];
}