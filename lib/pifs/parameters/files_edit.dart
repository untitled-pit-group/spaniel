import 'package:dartz/dartz.dart';
import 'package:spaniel/pifs/parameters/parameters.dart';
import "package:spaniel/pifs/support/json.dart";

class PifsFilesEditParameters implements Jsonable {
  /// The file ID.
  String fileId;

  /// The new filename of the file.
  /// 
  /// [None] implies that name shouldn't be changed.
  Option<String> name;

  /// An array of string tags. This will replace any tags previously set so
  /// should be used with care to prevent race conditions from losing data.
  /// 
  /// [None] implies that tags shouldn't be changed.
  Option<List<String>> tags;

  /// The relevance timestamp, or [null] if not set.
  ///
  /// [None] implies that the relevance timestamp shouldn't be changed. This is
  /// not the same as setting it to [Some(null)] which implies that it should
  /// be cleared.
  Option<DateTime?> relevanceTimestamp;

  PifsFilesEditParameters.blank(this.fileId) :
    name = const None(), tags = const None(), relevanceTimestamp = const None();

  void setName(String name) => this.name = Some(name);
  void unsetName() => name = const None();
  void setTags(List<String> tags) => this.tags = Some(tags);
  void unsetTags() => tags = const None();
  void setRelevanceTimestamp(DateTime? timestamp) => relevanceTimestamp = Some(timestamp);
  void unsetRelevanceTimestamp() => relevanceTimestamp = const None();

  @override dynamic toJson() {
    var json = <String, dynamic>{"file_id": fileId};
    name.fold(() {}, (name) { json["name"] = name; });
    tags.fold(() {}, (tags) { json["tags"] = tags; });
    relevanceTimestamp.fold(() {}, (timestamp) {
      json["relevance_timestamp"] = timestamp?.toIso8601String();
    });
    return json;
  }
}