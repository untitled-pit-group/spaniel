import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:spaniel/generated/l10n.dart";
import 'package:spaniel/pifs/fakes/offline_client.dart';
import 'package:spaniel/spaniel/bloc/file_list.dart';
import 'package:spaniel/spaniel/bloc/search.dart';
import "package:spaniel/spaniel/screens/home.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:spaniel/pifs/support/flutter.dart";

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
      home: PifsMockClientConnector(child: Builder(
        builder: (context) {
          final client = PifsClientProvider.of(context).client;
          if(client is PifsIndeterminateClient) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (client is PifsOfflineClient) {
            return const Icon(Icons.cloud_off);
          } else {
            return MultiBlocProvider(providers: [
              BlocProvider<SPFileList>(
                create: (_) => SPFileList(client: client)..add(SPFileListReload()),
              ),
              BlocProvider<SPSearchBloc>(
                create: (_) => SPSearchBloc(client: client),
              ),
            ], child: const SPHome());
          }
        }
      ))
    );
  }
}