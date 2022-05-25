import "package:spaniel/pifs/support/json.dart";

class PifsFilesDeleteParameters implements Jsonable {
  final String fileId;

  const PifsFilesDeleteParameters(this.fileId);

  @override dynamic toJson() {
    return <String, dynamic>{"file_id": fileId};
  }
}