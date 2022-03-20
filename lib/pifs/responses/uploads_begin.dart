class PifsUploadsBeginResponse {
  /// An upload ID. This is different from a file ID.
  final String uploadId;

  /// The GCS URL to perform the upload to.
  /// [null] if the file is already uploaded (its SHA-256 hash matches a known file.)
  final String? uploadUrl;

  PifsUploadsBeginResponse({
    required this.uploadId,
    this.uploadUrl
  });
}