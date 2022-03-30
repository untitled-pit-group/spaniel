import "package:spaniel/pifs/support/json.dart";

class PifsUploadId {
  final String raw;
  const PifsUploadId(this.raw);
}

class PifsUpload {
  final PifsUploadId id;
  final Uri uploadUrl;
  const PifsUpload(this.id, this.uploadUrl);

  factory PifsUpload.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final j = Unjsoner(json);
      final id = j.v<String>("upload_id");
      final url = j.vt("upload_url", Uri.tryParse);
      return PifsUpload(PifsUploadId(id), url);
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}