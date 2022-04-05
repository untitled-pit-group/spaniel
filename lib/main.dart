import "package:flutter/material.dart";
import "package:spaniel/generated/l10n.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/fakes/fake_client.dart";
import "package:spaniel/spaniel/screens/home.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:spaniel/foxhound/client.dart";

void main() {
  runApp(const SpanielApp());
}

class SpanielApp extends StatelessWidget {
  const SpanielApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "app_title",
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark
      ),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const SPHome()
    );
  }
}