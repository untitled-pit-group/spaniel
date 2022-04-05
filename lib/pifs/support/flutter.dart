import "dart:async";
import "package:flutter/material.dart";
import "package:spaniel/foxhound/client.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/fakes/fake_client.dart";
import "package:spaniel/pifs/fakes/offline_client.dart";
import 'package:spaniel/pifs/upload/fake_uploader.dart';
import 'package:spaniel/pifs/upload/gcs_uploader.dart';
import 'package:spaniel/pifs/upload/uploader.dart';

class PifsClientProvider extends InheritedWidget {
  final PifsClient client;
  final PifsUploader uploader;

  const PifsClientProvider({
    Key? key,
    required this.client,
    required this.uploader,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(PifsClientProvider oldWidget) =>
    oldWidget.client != client || oldWidget.uploader != uploader;

  static PifsClientProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PifsClientProvider>();
    assert(provider != null, "No PifsClientProvider found in context");
    return provider!;
  }
}

class _PifsClientConnectorState extends State<PifsFoxhoundClientConnector> {
  late PifsClient client;
  PifsUploader uploader = PifsGcsUploader();

  Future<void> _connect() async {
    final completer = Completer<PifsClient>.sync();
    client = PifsIndeterminateClient(completer.future);
    try {
      final client = await FoxhoundClient.build();
      setState(() {
        this.client = client;
        completer.complete(client);
      });
    } on Error {
      // TODO[pn]: This should probably be a bit more conditional than this
      // TODO[pn]: Connection should be retried on an interval *and* upon detecting any connectivity state changes
      setState(() {
        // TODO[pn]: [PifsOfflineReason.badSecret] should be detected
        client = const PifsOfflineClient(PifsOfflineReason.networkConnection);
        completer.complete(client);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    return PifsClientProvider(client: client, uploader: uploader,
      child: widget._child);
  }
}
class PifsFoxhoundClientConnector extends StatefulWidget {
  final Widget _child;
  const PifsFoxhoundClientConnector({
    Key? key,
    required Widget child,
  }) : _child = child, super(key: key);

  @override
  State<PifsFoxhoundClientConnector> createState() => _PifsClientConnectorState();
}

class PifsFakeClientConnector extends StatelessWidget {
  final Widget child;
  const PifsFakeClientConnector({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PifsClientProvider(
      client: PifsFakeClient.instance,
      uploader: PifsFakeUploader.instance,
      child: child,
    );
  }
}