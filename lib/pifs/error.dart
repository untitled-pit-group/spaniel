import "package:json_rpc_2/json_rpc_2.dart";
import "package:json_rpc_2/error_code.dart" as error_code;

typedef _PE = PifsError; // Shorthand

class PifsError {
  final String readableCode;
  final int code;

  /// The human-readable message returned from the server, if present. This may
  /// be absent when the error is created synthetically; this isn't guaranteed
  /// to have been localised when present.
  final String? serverMessage;

  /// Any extra data returned with the error. The interpretation depends on the
  /// particular error.
  final Object? data;

  // Prevent constructing from outside
  const PifsError._(this.code, this.readableCode, [this.serverMessage, this.data]);

  static const _readableCodes = {
    codeInvalidParams: "invalid_params",
    codeSizeLimitExceeded: "size_limit_exceeded",
    codeInProgress: "in_progress",
    codeStateError: "state_error",
    codeSyntaxError: "syntax_error",
    codeUnauthorized: "unauthorized",
    codeNotFound: "not_found",
    codeConflict: "conflict",
    codeInternalServerError: "internal_server_error",
  };

  static const codeInvalidParams = error_code.INVALID_PARAMS;
  static const codeSizeLimitExceeded = 1000;
  static const codeInProgress = 1001;
  static const codeStateError = 1002;
  static const codeSyntaxError = 1003;
  static const codeUnauthorized = 2401;
  static const codeNotFound = 2404;
  static const codeConflict = 2409;
  static const codeInternalServerError = 2500;

  factory PifsError.fromRpc(RpcException exc) {
    if (exc.code == codeInternalServerError &&
        exc.data is Map<String, dynamic> &&
        exc.data["exception"] != null) {
      return PifsRemoteError.fromRpc(exc);
    }
    return PifsError._(exc.code,
      _readableCodes[exc.code] ?? "unknown", exc.message, exc.data);
  }

  static _PE fromCode(int code) {
    final readableCode = _readableCodes[code];
    return _PE._(code, readableCode ?? "unknown");
  }

  @override
  String toString() {
    return 'PifsError{readableCode: $readableCode, code: $code, serverMessage: $serverMessage, data: $data}';
  }
}

/// A representation of an exception that happened within the server. This can
/// only be returned if the server itself is not in production mode.
class PifsRemoteError extends PifsError {
  final String remoteClass;
  final String? remoteMessage;
  final String remoteLocation;
  final List<String> remoteTrace;

  PifsRemoteError._({
    required int code,
    required String readableCode,
    required String serverMessage,
    required dynamic data,
    required this.remoteClass,
    required this.remoteMessage,
    required this.remoteLocation,
    required this.remoteTrace,
  }) : super._(code, readableCode, serverMessage, data);

  factory PifsRemoteError.fromRpc(RpcException exc) {
    Map<String, dynamic> data = exc.data;
    var exception = data["exception"];
    var message = data["message"];
    var location = data["location"];
    var trace = (data["trace"] as String).split("\n");
    return PifsRemoteError._(
      code: exc.code,
      readableCode: PifsError._readableCodes[exc.code] ?? "unknown",
      serverMessage: exc.message,
      data: data,
      remoteClass: exception,
      remoteMessage: message,
      remoteLocation: location,
      remoteTrace: trace,
    );
  }

  @override
  String toString() {
    return 'PifsRemoteError{remoteClass: $remoteClass, remoteMessage: $remoteMessage, remoteLocation: $remoteLocation, remoteTrace: $remoteTrace}';
  }
}