import "dart:async";
import "dart:typed_data";
import "package:http/http.dart";
import "package:spaniel/pifs/upload/uploader.dart";

class PifsGcsUploadError extends Error {
  final Response response;
  PifsGcsUploadError(this.response) : super();
}

class PifsGcsUploadTask implements PifsUploadTask {
  @override
  Stream<PifsUploadCheckpoint> get progress => _progress.stream;
  final StreamController<PifsUploadCheckpoint> _progress = StreamController.broadcast();

  @override
  double lastProgress = 0.0;

  final Stream<Uint8List> _chunkSource;
  late final StreamSubscription<Uint8List> _chunkSubscription;
  final Uri _target;
  late Uri _session;

  int _currentLength = 0;
  final int _totalLength;

  final Completer<void> _complete = Completer.sync();
  @override
  Future<void> get complete => _complete.future;

  PifsGcsUploadTask._(this._chunkSource, this._target, this._totalLength);

  static const chunkSize = 16*4 * 256*1024; // 16 MiB = 64 x 256 KiB
  final _chunkBuffer = BytesBuilder(copy: true);

  bool _finished = false;

  Future<void> _begin() async {
    try {
      await _initiateSession();
    } on Error catch (error, trace) {
      _complete.completeError(error, trace);
      return;
    }
    _chunkSubscription = _chunkSource.listen(
      _onChunk,
      onError: _finish,
      onDone: () => _onChunksDone(),
    );
  }
  Future<void> _initiateSession() async {
    var response = await post(_target, headers: {
      "Content-Length": "0",
      "Content-Type": "application/octet-stream",
      "x-goog-resumable": "start",
    });
    if (response.statusCode != 201) {
      throw PifsGcsUploadError(response);
    }
    _session = Uri.parse(response.headers["Location"]!);
  }

  void _notifyProgress() {
    final progress = _currentLength / _totalLength;
    _progress.add(PifsUploadCheckpoint(progress, _currentLength));
    lastProgress = progress;
  }
  void _finish([Object? error, StackTrace? trace]) {
    _finished = true;
    _chunkSubscription.cancel();

    if (error == null && _currentLength != _totalLength) {
      error = StateError(
        "Upload was finished prematurely without other errors -- file truncated?");
      trace = StackTrace.current;
    }

    if (error == null) {
      _progress.add(PifsUploadCheckpoint(1.0, _totalLength));
      _progress.close();
      lastProgress = 1.0;
      _complete.complete();
    } else {
      _progress.addError(error, trace);
      _progress.close();
      _complete.completeError(error, trace);
    }
  }

  void _onChunk(Uint8List chunk) {
    _chunkBuffer.add(chunk);
    if (_chunkBuffer.length >= chunkSize) {
      _chunkSubscription.pause(); // resume in _sendChunk
      _sendChunk().onError(_finish);
    }
  }
  void _onChunksDone() {
    if (_chunkBuffer.isNotEmpty) {
      _sendChunk().then(_finish, onError: _finish);
    } else {
      _finish();
    }
  }

  Future<void> _sendChunk() async {
    Uint8List chunk = _chunkBuffer.takeBytes();
    var firstByte = _currentLength;
    var lastByte = firstByte + chunk.length - 1;
    final isFinalChunk = lastByte == _totalLength - 1;
    var response = await put(_session, headers: {
      "Content-Length": chunk.length.toString(),
      "Content-Range": "bytes $firstByte-$lastByte/$_totalLength",
    }, body: chunk);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if ( ! isFinalChunk) {
        // BUG: GCS declared the upload finished prematurely. We can't really
        // handle this but continuing the upload will result in failure
        // regardless.
        throw StateError("GCS upload logic failure: upload finished prematurely");
      }
    } else if (response.statusCode != 308) {
      throw PifsGcsUploadError(response);
    }

    _currentLength += chunk.length;
    _notifyProgress();
    if ( ! isFinalChunk) {
      _chunkSubscription.resume();
    }
  }
}

class PifsGcsUploader implements PifsUploader {
  @override
  PifsUploadTask start({
    required Stream<Uint8List> chunkSource,
    required int length,
    required Uri target,
  }) {
    var task = PifsGcsUploadTask._(chunkSource, target, length);
    task._begin();
    return task;
  }
}
