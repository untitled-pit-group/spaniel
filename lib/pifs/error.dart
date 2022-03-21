import "package:json_rpc_2/json_rpc_2.dart";
import "package:json_rpc_2/error_code.dart" as error_code;

typedef _PE = PifsError; // Shorthand

/// Enum like class that stores all known PIFS errors, and can retrieve
/// an error by code.
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
  };

  static const codeInvalidParams = error_code.INVALID_PARAMS;
  static const codeSizeLimitExceeded = 1000;
  static const codeInProgress = 1001;
  static const codeStateError = 1002;
  static const codeSyntaxError = 1003;
  static const codeUnauthorized = 2401;
  static const codeNotFound = 2404;
  static const codeConflict = 2409;

  factory PifsError.fromRpc(RpcException exc) => PifsError._(exc.code,
    _readableCodes[exc.code] ?? "unknown", exc.message, exc.data);

  static _PE fromCode(int code) {
    final readableCode = _readableCodes[code];
    return _PE._(code, readableCode ?? "unknown");
  }
}