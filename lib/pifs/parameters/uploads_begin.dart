import 'package:spaniel/pifs/support/json.dart';

class PifsUploadsBeginParameters implements Jsonable {
  final String hash;
  final int length;
  final String name;

  const PifsUploadsBeginParameters(this.hash, this.length, this.name);

  @override
  dynamic toJson() {
    return {"hash": hash, "length": length, "name": name};
  }
}