import "dart:async";
import "package:http/http.dart" as http;
import "package:spaniel/config.dart";
import "package:stream_channel/stream_channel.dart";

class _FXConnectionSink implements StreamSink<String> {
  final _done = Completer<void>();
  final FXConnection connection;

  _FXConnectionSink._(this.connection);

  @override
  void add(String event) {
    connection.sendRequest(event);
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

class FXConnectionError extends Error {
  final http.Response response;
  FXConnectionError(this.response);

  @override
  String toString() {
    return 'FXConnectionError ${response.statusCode}: ${response.body}';
  }
}

class FXConnection with StreamChannelMixin<String> implements StreamChannel<String> {
  final _stream = StreamController<String>();
  late final _FXConnectionSink _sink;

  final http.Client _connection;
  final String _sessionKey;

  static const _userAgent = "PIFS/version-undefined";

  FXConnection._(this._connection, this._sessionKey) {
    _sink = _FXConnectionSink._(this);
  }

  static Future<FXConnection> connect(http.Client connection, String secretKey) async {
    var resp = await connection.post(Uri.parse(Config.fxEndpoint).replace(path: "/auth-token"),
      headers: {"User-Agent": _userAgent}, body: secretKey);
    if (resp.statusCode != 200) {
      throw FXConnectionError(resp);
    }
    var sessionKey = resp.body.trimRight();
    return FXConnection._(connection, sessionKey);
  }

  void sendRequest(String request) {
    var uri = Uri.parse(Config.fxEndpoint).replace(path: "/rpc");
    _connection
      .post(uri, headers: {
        "Authorization": "Bearer $_sessionKey",
        "Content-Type": "application/json; charset=UTF-8",
        "User-Agent": _userAgent,
      }, body: request)
      .then((response) {
        _stream.add(response.body);
      });
  }

  @override
  StreamSink<String> get sink => _sink;

  @override
  Stream<String> get stream => _stream.stream;
}