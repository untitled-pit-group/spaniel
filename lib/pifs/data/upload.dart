import 'package:spaniel/pifs/support/json.dart';

/// Represents an in-progress upload.
class PifsUploadId {
  final String raw;
  const PifsUploadId(this.raw);
}

/// Represents the target URL to perform the upload to.
class PifsUploadUrl {
  final String raw;
  const PifsUploadUrl(this.raw);
}

class PifsUpload {
  final PifsUploadId id;
  final PifsUploadUrl url;
  const PifsUpload(this.id, this.url);

  static JsonBuilder<PifsUpload> jsonBuilder = _PifsUploadJsonBuilder.instance;
}
class _PifsUploadJsonBuilder implements JsonBuilder<PifsUpload> {
  static const instance = _PifsUploadJsonBuilder();
  const _PifsUploadJsonBuilder();
  @override
  PifsUpload fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final id = PifsUploadId(json["id"]);
      final url = PifsUploadUrl(json["url"]);
      return PifsUpload(id, url);
    } else {
      throw Exception("Cannot parse PifsUpload from non-object JSON");
    }
  } 
}