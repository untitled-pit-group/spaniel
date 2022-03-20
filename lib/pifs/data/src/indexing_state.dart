enum PifsIndexingState {
  unknown,
  /// The file is in queue waiting to be indexed.
  waitingForProcessing,
  /// The file is being parsed to extract its contents.
  /// For media files, this indicates only transcoding the audio into a transcription-compatible format.
  parsing,
  /// A media file is pending transcription by an external service.
  /// This state is never set for documents.
  pendingTranscription,
  /// The file is pending to be added to the search index.
  pendingIndexing,
  /// The file has been fully indexed and is at rest.
  indexed,
  /// An error has occured during transcoding, extraction or indexing.
  error
}

class PifsIndexingStateHelper {
  static PifsIndexingState getFromInt(int state) {
    switch(state) {
      case 0: return PifsIndexingState.waitingForProcessing;
      case 1: return PifsIndexingState.parsing;
      case 2: return PifsIndexingState.pendingTranscription;
      case 3: return PifsIndexingState.pendingIndexing;
      case 4: return PifsIndexingState.indexed;
      case -1: return PifsIndexingState.error;
      default: return PifsIndexingState.unknown;
    }
  }
}