import "dart:convert";
import "dart:math";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:list_ext/list_ext.dart";
import "package:spaniel/pifs/objects/file.dart";
import "package:crypto/crypto.dart";
import "package:spaniel/spaniel/screens/upload.dart";
import "package:spaniel/spaniel/widgets/file_item.dart";

const _chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class SPHome extends StatelessWidget {
  const SPHome({Key? key}) : super(key: key);

  PifsFile _generateFakeFile() => PifsFile(
      id: getRandomString(16),
      name: getRandomString(16),
      tags: ["Iyama Tag", "Birka", "Kakas Emodži", "💩"],
      uploadTimestamp: DateTime.now().subtract(Duration(hours: Random().nextInt(5000))),
      relevanceTimestamp: Random().nextBool() ? DateTime.now().subtract(Duration(hours: Random().nextInt(5000))) : null,
      length: Random().nextInt(500000),
      hash: sha256.convert(utf8.encode(getRandomString(20))).toString(),
      type: ["document", "plain", "media"].random,
      indexingState: Random().nextInt(5)
  );

  Widget _getFileList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("my_files".tr, style: Get.theme.textTheme.headlineLarge),
        ...List.generate(20, (_) => _generateFakeFile())
          .map((e) => SPFileItem(file: e))
      ]
    );
  }

  Widget _getContents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _getFileList(context)
      ],
    );
  }

  Widget _getBody(BuildContext context) {
    return SingleChildScrollView(
      child: _getContents(context)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("home_title".tr)
      ),
      body: _getBody(context),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: () {
          Get.to(SPUpload());
        },
      ),
    );
  }
}