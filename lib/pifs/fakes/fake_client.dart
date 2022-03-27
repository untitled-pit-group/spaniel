import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/data/upload.dart";
import "package:spaniel/pifs/parameters/files_edit.dart";
import "package:spaniel/pifs/parameters/uploads_begin.dart";
import "package:spaniel/pifs/parameters/uploads_cancel.dart";
import "package:spaniel/pifs/parameters/uploads_finish.dart";
import "package:spaniel/pifs/responses/null_response.dart";

class PifsFakeClient implements PifsClient {
  static Future<PifsFakeClient> build() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PifsFakeClient();
  }

  @override
  PifsResponse<PifsFile> filesEdit(PifsFilesEditParameters params) {
    throw UnimplementedError();
  }

  @override
  PifsResponse<List<PifsFile>> filesList() {
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsUpload> uploadBegin(PifsUploadsBeginParameters params) {
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsNullResponse> uploadCancel(PifsUploadsCancelParameters params) {
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsFile> uploadFinish(PifsUploadsFinishParameters params) {
    throw UnimplementedError();
  }
}