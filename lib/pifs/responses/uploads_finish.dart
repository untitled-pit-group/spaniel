import 'package:spaniel/pifs/objects/file.dart';

class PifsUploadsFinishResponse {
  // A [PifsFile] object, corresponding to the upload.
  // The file is guaranteed to have indexing_state of 0.
  final PifsFile file;

  const PifsUploadsFinishResponse(this.file);
}