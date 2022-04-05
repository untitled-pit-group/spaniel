import "dart:convert";
import "dart:math";
import "package:crypto/crypto.dart";
import "package:dartz/dartz.dart";
import "package:list_ext/list_ext.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/data/upload.dart";
import "package:spaniel/pifs/parameters/parameters.dart";
import "package:spaniel/pifs/responses/responses.dart";

class PifsFakeClient implements PifsClient {
  static const _chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

  PifsFile _generateFakeFile() {
    final Random _rnd = Random();
    return PifsFile(
      id: getRandomString(16),
      name: getRandomString(16),
      tags: ["Iyama Tag", "Birka", "Kakas Emodži", "💩", "asdasd", "Baba", "Booey", "A really long tag that should cause the UI to act weird like overflow and shit"].where((_) => _rnd.nextBool()).toList(),
      uploadTimestamp: DateTime.now().subtract(Duration(hours: _rnd.nextInt(5000))),
      relevanceTimestamp: _rnd.nextBool() ? DateTime.now().subtract(Duration(hours: _rnd.nextInt(5000))) : null,
      length: _rnd.nextInt(500000),
      hash: sha256.convert(utf8.encode(getRandomString(20))).toString(),
      type: ["document", "plain", "media"].random,
      indexingState: -1 + _rnd.nextInt(6)
  );
  }

  const PifsFakeClient();
  static const instance = PifsFakeClient();

  @override
  PifsResponse<PifsFile> filesEdit(PifsFilesEditParameters params) {
    throw UnimplementedError();
  }

  @override
  PifsResponse<List<PifsFile>> filesList() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Left(List.generate(30, (_) => _generateFakeFile()));
  }

  @override
  PifsResponse<PifsUpload> uploadBegin(PifsUploadsBeginParameters params) {
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsNullResponse> uploadCancel(PifsUploadsCancelParameters params) {
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsFile> uploadFinish(PifsUploadsFinishParameters params) {
    throw UnimplementedError();
  }
}