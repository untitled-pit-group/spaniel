import "dart:convert";
import "dart:math";
import "package:crypto/crypto.dart";
import "package:dartz/dartz.dart";
import "package:list_ext/list_ext.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import 'package:spaniel/pifs/data/search_result.dart';
import 'package:spaniel/pifs/data/src/range.dart';
import 'package:spaniel/pifs/error.dart';
import 'package:spaniel/pifs/fakes/fake_client.dart';
import 'package:spaniel/pifs/parameters/parameters.dart';

class PifsMockClient extends PifsFakeClient {
  static final instance = PifsMockClient();
  PifsMockClient();

  static const _chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

  PifsFile _generateFakeFile() {
    final Random _rnd = Random();
    return PifsFile(
      id: getRandomString(16),
      name: getRandomString(16),
      tags: ["Iyama Tag", "Birka", "Kakas Emodži", "💩", "asdasd", "Baba", "Booey", "A really long tag that should cause the UI to act weird like overflow and shit"].where((_) => _rnd.nextBool()).toSet(),
      uploadTimestamp: DateTime.now().subtract(Duration(hours: _rnd.nextInt(5000))),
      relevanceTimestamp: _rnd.nextBool() ? DateTime.now().subtract(Duration(hours: _rnd.nextInt(5000))) : null,
      length: _rnd.nextInt(500000),
      hash: sha256.convert(utf8.encode(getRandomString(20))).toString(),
      type: PifsFileType.values.random,
      indexingState: PifsIndexingState.values.random,
    );
  }

  PifsPlainSearchResult _generateFakePlainResult() {
    final Random _rnd = Random();
    return PifsPlainSearchResult(
      fileId: getRandomString(16),
      fragment: "The mišsle kn0ws wh🙈🤪你好 čau",
      ranges: [PifsRange(7,15),PifsRange(18,22)]
    );
  }

  List<PifsFile>? files;

  @override
  PifsResponse<List<PifsFile>> filesList() async {
    await Future.delayed(const Duration(milliseconds: 200));
    files ??= List.generate(30, (_) => _generateFakeFile());
    return Left(files!);
  }

  @override
  PifsResponse<List<PifsSearchResult>> searchPerform(PifsSearchPerformParameters params) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Left(List.generate(30, (_) => _generateFakePlainResult()));
  }

  @override
  PifsResponse<PifsFile> filesEdit(PifsFilesEditParameters params) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if(files == null) {
      return Right(PifsError.fromCode(2404));
    }
    final f = files!.firstWhere((e) => e.id == params.fileId);
    final newf = PifsFile(
        id: f.id,
        name: params.name.fold(() => f.name, (a) => a),
        tags: params.tags.fold(() => f.tags, (a) => a),
        uploadTimestamp: f.uploadTimestamp,
        relevanceTimestamp: params.relevanceTimestamp.fold(() => f.relevanceTimestamp, (a) => a),
        length: f.length,
        hash: f.hash,
        removalDeadline: f.removalDeadline,
        type: f.type,
        indexingState: f.indexingState
    );
    files![files!.indexWhere((e) => e.id == params.fileId)] = newf;
    return Left(newf);
  }
}