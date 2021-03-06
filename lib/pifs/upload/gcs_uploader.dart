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

  /// Keep an instance of a Client around so that we don't have to open a new
  /// connection every time.
  final Client _connection = Client();

  final Completer<void> _complete = Completer.sync();
  @override
  Future<void> get complete => _complete.future;

  static const _gcsChunkStride = 256 * 1024; // 256 KiB

  PifsGcsUploadTask._(this._chunkSource, this._target, this._totalLength) {
    // GCS has a hard limit of 10_000 chunks. We need at least 100 to have a
    // meaningful semblance of progress.
    var maxChunk = (this._totalLength / 100).floor();
    // Round down to the nearest power of 256 KiB.
    maxChunk -= maxChunk % _gcsChunkStride;
    if (maxChunk == 0) {
      // If the chunk size is below stride, just deal with it and use chunks of
      // the smallest size.
      maxChunk = _gcsChunkStride;
    }
    assert(maxChunk % _gcsChunkStride == 0);
    assert(maxChunk > 0);
    _chunkSize = maxChunk;
  }

  late final int _chunkSize;
  final _chunkBuffer = BytesBuilder(copy: true);

  bool _finished = false;

  Future<void> _begin() async {
    try {
      await _initiateSession();
    } on Error catch (error, trace) {
      _complete.completeError(error, trace);
      return;
    }
    if (_finished) {
      // Upload was cancelled while the session was being initiated.
      _teardownSession();
      return;
    }
    _chunkSubscription = _chunkSource.listen(
      _onChunk,
      onError: _finish,
      onDone: () => _onChunksDone(),
    );
  }
  Future<void> _initiateSession() async {
    var response = await _connection.post(_target, headers: {
      "Content-Length": "0",
      "Content-Type": "application/octet-stream",
      "x-goog-resumable": "start",
    });
    if (response.statusCode != 201) {
      throw PifsGcsUploadError(response);
    }
    _session = Uri.parse(response.headers["location"]!);
  }
  Future<void> _teardownSession() async {
    await _connection.delete(_session, headers: {"Content-Length": "0"});
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
      _notifyProgress();
      _progress.close();
      _complete.complete();
    } else {
      _progress.close();
      _complete.completeError(error, trace);
    }
  }

  @override
  void cancel() {
    _finish(PifsUploadInterruptedError(), StackTrace.current);
    if (_session != null) {
      _teardownSession();
    }
  }

  void _onChunk(Uint8List chunk) {
    _chunkBuffer.add(chunk);
    if (_chunkBuffer.length >= _chunkSize) {
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
    var response = await _connection.put(_session, headers: {
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
