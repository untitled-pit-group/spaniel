import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:spaniel/l10n/l10n.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/fakes/fake_client.dart";
import "package:spaniel/spaniel/screens/home.dart";

import "package:spaniel/foxhound/client.dart";

void main() {
  runApp(const SpanielApp());
}

class SpanielApp extends StatelessWidget {
  const SpanielApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "app_title".tr,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark
      ),
      locale: Get.deviceLocale,
      translations: PifsLocalization(),
      home: Builder(
        builder: (context) {
          Get.putAsync<PifsClient>(PifsFakeClient.build);
          return const SPHome();
        }
      ),
    );
  }
}