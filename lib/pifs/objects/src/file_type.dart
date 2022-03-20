enum PifsFileType {
  unknown, document, plain, media
}

class PifsFileTypeHelper {
  static PifsFileType getFromString(String type) {
    switch(type.toLowerCase()) {
      case "document": return PifsFileType.document;
      case "plain": return PifsFileType.plain;
      case "media": return PifsFileType.media;
      default: return PifsFileType.unknown;
    }
  }
}