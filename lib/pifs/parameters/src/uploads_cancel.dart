import "package:spaniel/pifs/data/upload.dart";
import "package:spaniel/pifs/support/json.dart";

class PifsUploadsCancelParameters implements Jsonable {
  final PifsUploadId id;

  const PifsUploadsCancelParameters(this.id);

  @override
  dynamic toJson() {
    return {"upload_id": id.raw};
  }
}