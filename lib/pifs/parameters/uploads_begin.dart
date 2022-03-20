class PifsUploadsBeginParameters {
  /// The file's SHA-256 hash, in hex form.
  final String hash;

  /// The file's length in bytes.
  final int length;

  /// The file's name.
  /// This is unrelated to the name provided at uploads.finish and intended for display purposes
  /// to clients other than the requester which are interested in ongoing upload progress.
  final String name;

  const PifsUploadsBeginParameters({
    required this.hash,
    required this.length,
    required this.name
  });
}