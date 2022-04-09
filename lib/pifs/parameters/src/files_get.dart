import "package:spaniel/pifs/support/json.dart";

class PifsFilesGetParameters implements Jsonable {
  final String fileId;

  const PifsFilesGetParameters(this.fileId);

  @override dynamic toJson() {
    return <String, dynamic>{"file_id": fileId};
  } 
}