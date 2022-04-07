import "package:spaniel/pifs/data/upload.dart";
import "package:spaniel/pifs/support/json.dart";

class PifsUploadsFinishParameters implements Jsonable {
  /// The upload ID, as returned by uploads.begin.
  final PifsUploadId uploadId;

  /// The file's name, as provided by the filesystem or set by the user
  /// interim uploads.begin and now.
  final String name;

  /// An array of string tags to be applied to the file.
  final List<String> tags;

  /// The relevance timestamp for the file, as specified by the user, in the same format as a Timestamp.
  final DateTime? relevanceTimestamp;

  const PifsUploadsFinishParameters({
    required this.uploadId,
    required this.name,
    required this.tags,
    this.relevanceTimestamp
  });

  @override
  toJson() {
    return <String, dynamic>{
      "upload_id": uploadId.raw,
      "name": name,
      "tags": tags,
      "relevance_timestamp": relevanceTimestamp?.toIso8601String(),
    };
  } 
}