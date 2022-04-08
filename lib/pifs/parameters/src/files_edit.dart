import 'package:dartz/dartz.dart';
import "package:spaniel/pifs/support/json.dart";
import 'package:spaniel/pifs/util/dartz.dart';

class PifsFilesEditParameters implements Jsonable {
  /// The file ID.
  final String fileId;

  /// The new filename of the file.
  final Option<String> name;

  /// An array of string tags. This will replace any tags previously set so should be used with care to prevent race conditions from losing data.
  final Option<Set<String>> tags;

  /// A string containing an RFC 3339 datetimestamp with second precision or [null] if not set.
  final Option<DateTime?> relevanceTimestamp;


  PifsFilesEditParameters({
    required this.fileId,
    this.name = const None(),
    this.tags = const None(),
    this.relevanceTimestamp = const None(),
  });

  @override dynamic toJson() {
    return <String, dynamic>{
      "file_id": fileId,
      if (name is Some) "name": name.unwrapped,
      if (tags is Some) "tags": tags.unwrapped.toList(growable: false),
      if (relevanceTimestamp is Some)
        "relevance_timestamp": relevanceTimestamp.unwrapped?.toIso8601String(),
    };
  }
}