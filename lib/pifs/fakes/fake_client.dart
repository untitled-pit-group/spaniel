import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import 'package:spaniel/pifs/data/search_result.dart';
import "package:spaniel/pifs/data/upload.dart";
import "package:spaniel/pifs/parameters/parameters.dart";
import "package:spaniel/pifs/responses/responses.dart";

class PifsFakeClient implements PifsClient {
  const PifsFakeClient();
  static const instance = PifsFakeClient();

  @override
  PifsResponse<PifsFile> filesEdit(PifsFilesEditParameters params) {
    throw UnimplementedError();
  }

  @override
  PifsResponse<List<PifsFile>> filesList() {
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsTargetableUpload> uploadBegin(PifsUploadsBeginParameters params) {
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

  @override
  PifsResponse<List<PifsSearchResult>> searchPerform(PifsSearchPerformParameters params) {
    throw UnimplementedError();
  }
}