import "package:spaniel/pifs/support/json.dart";

class PifsUploadsBeginParameters implements Jsonable {
  /// The file's SHA-256 hash, in hex form.
  final String hash;

  /// The file's length in bytes.
  final int length;

  /// The file's name.
  /// This is unrelated to the name provided at uploads.finish and intended for display purposes
  /// to clients other than the requester which are interested in ongoing upload progress.
  final String name;

  const PifsUploadsBeginParameters(this.hash, this.length, this.name);

  @override
  dynamic toJson() {
    return {"hash": hash, "length": length, "name": name};
  }
}