import "dart:io";
import "dart:typed_data";

class PifsUploadCheckpoint {
  /// A value between 0.0 and 1.0 representing the amount of data uploaded
  /// when the checkpoint was emitted.
  final double progress;

  /// The precise number of bytes that had been uploaded when then checkpoint
  /// was emitted.
  final int bytes;
  const PifsUploadCheckpoint(this.progress, this.bytes);
}

/// An instance of this error is throw in the [complete] future of
/// [PifsUploadTask] if the upload is cancelled before finishing.
class PifsUploadInterruptedError extends Error {}

abstract class PifsUploadTask {
  /// A broadcast [Stream] of checkpoint events. The stream will always be
  /// closed when the upload is finished or interrupted, though errors will
  /// only be delivered to the [complete] future; this stream will simply get
  /// closed.
  Stream<PifsUploadCheckpoint> get progress;

  double get lastProgress;

  /// A [Future] that resolves when the upload is complete.
  Future<void> get complete;

  /// Cancel the upload. Causes a [PifsUploadCancelledError] to be returned from
  /// the [complete] future.
  void cancel();
}

/// Interface for backends for uploading.
/// 
/// The Uploader instance is responsible for keeping track of any [PifsUploadTask]s
/// in progress. This is important if the app is forced to suspend and abort
/// any in-progress uploads; if the upload state is persisted well, the tasks
/// should be resumable after a rehydration from the place they left off.
abstract class PifsUploader {
  /// Spawn an upload task. The task begins executing on the event loop in the
  /// background.
  PifsUploadTask start({
    /// A source of data chunks. This stream must be a single-subscription
    /// stream; the single subscription will be used to provide backpressure.
    /// When the subscription is cancelled, the stream should be disposed of.
    required Stream<Uint8List> chunkSource,

    /// The total length of the file. The total length of all chunks within
    /// [chunkSource] must add up exactly to [length].
    required int length,

    /// The target URI to upload to. Presumably the implementation of
    /// [PifsUploader] is able to handle this kind of URI.
    required Uri target,
  });
}