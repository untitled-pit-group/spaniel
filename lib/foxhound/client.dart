import 'package:spaniel/pifs/api.dart';
import 'package:spaniel/pifs/parameters/uploads_begin.dart';
import 'package:spaniel/pifs/parameters/uploads_cancel.dart';
import 'package:spaniel/pifs/parameters/uploads_finish.dart';
import 'package:spaniel/pifs/responses/uploads_begin.dart';
import 'package:spaniel/pifs/responses/uploads_cancel.dart';
import 'package:spaniel/pifs/responses/uploads_finish.dart';

class FoxhoundClient implements PifsApi {
  @override
  PifsResponse<PifsUploadsBeginResponse> uploadBegin(PifsUploadsBeginParameters params) {
    // TODO: implement uploadBegin
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsUploadsCancelResponse> uploadCancel(PifsUploadsCancelParameters params) {
    // TODO: implement uploadCancel
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsUploadsFinishResponse> uploadFinish(PifsUploadsFinishParameters params) {
    // TODO: implement uploadFinish
    throw UnimplementedError();
  }
}