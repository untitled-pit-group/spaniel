import "package:dartz/dartz.dart";
import "package:spaniel/pifs/error.dart";
import "package:spaniel/pifs/parameters/uploads_begin.dart";
import "package:spaniel/pifs/parameters/uploads_cancel.dart";
import "package:spaniel/pifs/parameters/uploads_finish.dart";
import "package:spaniel/pifs/responses/files_list.dart";
import "package:spaniel/pifs/responses/null_response.dart";
import "package:spaniel/pifs/responses/uploads_begin.dart";
import "package:spaniel/pifs/responses/uploads_finish.dart";

typedef PifsResponse<T> = Future<Either<T, PifsError>>;

/// Interface for PIFS API clients.
abstract class PifsClient {
  /// Mint a GCS signed target URL to perform a file upload onto.
  /// The logistics of the upload and long-term storage are handled by GCS, not by the API server.
  PifsResponse<PifsUploadsBeginResponse> uploadBegin(PifsUploadsBeginParameters params);

  /// Report to the server that a file upload has been finished and any necessary processing can begin.
  /// This MUST be called only after the entire file is uploaded and finalized.
  PifsResponse<PifsUploadsFinishResponse> uploadFinish(PifsUploadsFinishParameters params);

  /// Request the server to clean up any state associated with this file, including deleting any partial uploaded data from GCS.
  PifsResponse<PifsNullResponse> uploadCancel(PifsUploadsCancelParameters params);

  /// List all uploaded files.
  PifsResponse<PifsFilesListResponse> filesList();
}