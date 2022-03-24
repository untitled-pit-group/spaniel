import "package:spaniel/pifs/support/json.dart";

class PifsFilesEditParameters implements Jsonable {
  /// The file ID.
  final String fileId;

  /// The new filename of the file.
  final String name;

  /// An array of string tags. This will replace any tags previously set so should be used with care to prevent race conditions from losing data.
  final List<String> tags;

  /// A string containing an RFC 3339 datetimestamp with second precision or [null] if not set.
  final DateTime? relevanceTimestamp;


  PifsFilesEditParameters({
    required this.fileId,
    required this.name,
    required this.tags,
    required this.relevanceTimestamp
  });

  @override dynamic toJson() {
    return {
      "file_id": fileId,
      "name": name,
      "tags": tags,
      "relevanceTimestamp": relevanceTimestamp?.toIso8601String()
    };
  }
}