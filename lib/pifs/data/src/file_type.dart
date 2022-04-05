enum PifsFileType {
  document, plain, media
}

class PifsFileTypeHelper {
  static PifsFileType getFromString(String type) {
    switch(type.toLowerCase()) {
      case "document": return PifsFileType.document;
      case "plain": return PifsFileType.plain;
      case "media": return PifsFileType.media;
      default: throw ArgumentError.value(type, "type");
    }
  }

  static bool isValid(String type) {
    try {
      getFromString(type);
      return true;
    } on ArgumentError {
      return false;
    }
  }
}