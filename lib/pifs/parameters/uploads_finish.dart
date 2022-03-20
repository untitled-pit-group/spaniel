class PifsUploadsFinishParameters {
  /// The upload ID, as returned by uploads.begin.
  final String uploadId;

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
}