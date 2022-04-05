enum PifsIndexingState {
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
  static const codeWaitingForProcessing = 0;
  static const codeParsing = 1;
  static const codePendingTranscription = 2;
  static const codePendingIndexing = 3;
  static const codeIndexed = 4;
  static const codeError = -1;

  static PifsIndexingState getFromInt(int state) {
    switch(state) {
      case codeWaitingForProcessing:
        return PifsIndexingState.waitingForProcessing;
      case codeParsing:
        return PifsIndexingState.parsing;
      case codePendingTranscription:
        return PifsIndexingState.pendingTranscription;
      case codePendingIndexing:
        return PifsIndexingState.pendingIndexing;
      case codeIndexed:
        return PifsIndexingState.indexed;
      case codeError:
        return PifsIndexingState.error;
      default:
        throw ArgumentError.value(state, "state");
    }
  }

  static bool isValid(int state) {
    try {
      getFromInt(state);
      return true;
    } on ArgumentError {
      return false;
    }
  }
}