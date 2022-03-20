import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/parameters/uploads_begin.dart";
import "package:spaniel/pifs/parameters/uploads_cancel.dart";
import "package:spaniel/pifs/parameters/uploads_finish.dart";
import "package:spaniel/pifs/responses/files_list.dart";
import "package:spaniel/pifs/responses/null_response.dart";
import "package:spaniel/pifs/responses/uploads_begin.dart";
import "package:spaniel/pifs/responses/uploads_finish.dart";

class FoxhoundClient implements PifsClient {
  @override
  PifsResponse<PifsUploadsBeginResponse> uploadBegin(PifsUploadsBeginParameters params) {
    // TODO: implement uploadBegin
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsNullResponse> uploadCancel(PifsUploadsCancelParameters params) {
    // TODO: implement uploadCancel
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsUploadsFinishResponse> uploadFinish(PifsUploadsFinishParameters params) {
    // TODO: implement uploadFinish
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsFilesListResponse> filesList() {
    // TODO: implement filesList
    throw UnimplementedError();
  }
}