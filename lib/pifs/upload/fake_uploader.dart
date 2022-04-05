import 'dart:async';
import 'dart:typed_data';

import "package:spaniel/pifs/upload/uploader.dart";

class PifsFakeUploadTask implements PifsUploadTask {
  @override
  late Future<void> complete;

  @override
  double lastProgress = 0.0;

  @override
  Stream<PifsUploadCheckpoint> get progress => _progress.stream;
  final StreamController<PifsUploadCheckpoint> _progress = StreamController.broadcast();

  Stream<Uint8List> _chunkSource;
  int _length;
  PifsFakeUploadTask._(this._chunkSource, this._length, Uri target);

  void _begin() {
    complete = _run();
  }
  Future<void> _run() async {
    try {
      await _chunkSource.drain();
      _progress.add(PifsUploadCheckpoint(1.0, _length));
      lastProgress = 1.0;
      _progress.close();
    } on Error catch (error, stack) {
      _progress.addError(error, stack);
      _progress.close();
      rethrow;
    }
  }
}

/// An uploader that discards all incoming data and pretends that it was uploaded
/// successfully.
class PifsFakeUploader implements PifsUploader {
  static const instance = PifsFakeUploader();
  const PifsFakeUploader();

  @override
  PifsUploadTask start({
    required Stream<Uint8List> chunkSource,
    required int length,
    required Uri target,
  }) {
    final task = PifsFakeUploadTask._(chunkSource, length, target);
    task._begin();
    return task;
  }
}