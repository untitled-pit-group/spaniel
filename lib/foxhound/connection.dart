import 'package:async/src/stream_sink_transformer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:spaniel/config.dart';
import 'package:stream_channel/stream_channel.dart';

class _FxConnectionSink implements StreamSink<String> {
  final _done = Completer<void>();
  final FxConnection _connection;

  _FxConnectionSink._(this._connection);

  @override
  void add(String event) {
    _connection.sendRequest(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _done.completeError(error, stackTrace);
  }

  @override
  Future addStream(Stream<String> stream) {
    stream.forEach(add);
    return done;
  }

  @override
  Future close() {
    _done.complete();
    return done;
  }

  @override
  Future get done => _done.future;
}

class FxConnection with StreamChannelMixin<String> implements StreamChannel<String> {
  final _stream = StreamController<String>();
  late final _FxConnectionSink _sink;

  final http.Client _connection;
  final String _secretKey;
  String _sessionKey;

  FxConnection._(this._connection, this._secretKey, this._sessionKey) {
    _sink = _FxConnectionSink._(this);
  }

  static Future<FxConnection> connect(http.Client connection, String secretKey) async {
    var resp = await connection.post(Uri.parse(Config.fxEndpoint),
      headers: {/* TODO[pn] */}, body: secretKey);
    var sessionKey = resp.body;
    return FxConnection._(connection, secretKey, sessionKey);
  }

  void sendRequest(String request) {
    var uri = Uri.parse(Config.fxEndpoint).replace(path: "/rpc");
    _connection.post(uri, headers: {/* TODO[pn] */}, body: request).then((response) {
      _stream.add(response.body);
    });
  }

  @override
  StreamSink<String> get sink => _sink;

  @override
  Stream<String> get stream => _stream.stream;
}