import 'package:dartz/dartz.dart';
import 'package:spaniel/pifs/error.dart';
import 'package:spaniel/pifs/parameters/uploads_begin.dart';
import 'package:spaniel/pifs/parameters/uploads_cancel.dart';
import 'package:spaniel/pifs/parameters/uploads_finish.dart';
import 'package:spaniel/pifs/responses/uploads_begin.dart';
import 'package:spaniel/pifs/responses/uploads_cancel.dart';
import 'package:spaniel/pifs/responses/uploads_finish.dart';

typedef PifsResponse<T> = Future<Either<T, PifsError>>;

/// Interface for PIFS API clients.
abstract class PifsApi {
  PifsResponse<PifsUploadsBeginResponse> uploadBegin(PifsUploadsBeginParameters params);
  PifsResponse<PifsUploadsFinishResponse> uploadFinish(PifsUploadsFinishParameters params);
  PifsResponse<PifsUploadsCancelResponse> uploadCancel(PifsUploadsCancelParameters params);
}