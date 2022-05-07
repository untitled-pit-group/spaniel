import "package:spaniel/pifs/support/json.dart";

class PifsUploadId {
  final String raw;
  const PifsUploadId(this.raw);
}

class PifsUpload {
  final PifsUploadId id;
  final String hash;
  final double progress;
  final String name;
  const PifsUpload({
    required this.id,
    required this.hash,
    required this.progress,
    required this.name,
  });

  factory PifsUpload.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final j = Unjsoner(json);
      return PifsUpload(
        id: PifsUploadId(j.v("id")),
        hash: j.v("hash"),
        progress: j.v<num>("progress").toDouble(),
        name: j.v("name"),
      );
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}

class PifsTargetableUpload extends PifsUpload {
  final Uri uploadUrl;
  const PifsTargetableUpload({
    required PifsUploadId id,
    required String hash,
    required double progress,
    required String name,
    required this.uploadUrl,
  }) : super(id: id, hash: hash, progress: progress, name: name);

  factory PifsTargetableUpload.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final j = Unjsoner(json);
      return PifsTargetableUpload(
        id: PifsUploadId(j.v("id")),
        hash: j.v("hash"),
        progress: j.v<num>("progress").toDouble(),
        name: j.v("name"),
        uploadUrl: j.vt("gcs_url", Uri.tryParse),
      );
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}