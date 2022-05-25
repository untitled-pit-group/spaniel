import "package:spaniel/pifs/support/json.dart";

class PifsFilesRequestDownloadParameters implements Jsonable {
  final String fileId;

  const PifsFilesRequestDownloadParameters(this.fileId);

  @override dynamic toJson() {
    return <String, dynamic>{"file_id": fileId};
  }
}