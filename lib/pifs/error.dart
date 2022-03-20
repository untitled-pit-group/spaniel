import 'package:collection/collection.dart';

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
    -32602: "invalid_params",
    1000: "size_limit_exceeded",
    1001: "in_progress",
    2404: "not_found",
    2409: "conflict",
  };

  static _PE fromCode(int code) {
    final readableCode = _readableCodes[code];
    return _PE._(code, readableCode ?? "unknown");
  }

  static _PE fromJsonRepresentation(Map<String, dynamic> jsonRepresentation) {
    final code = jsonRepresentation["code"];
    if (code == null || code is! int) {
      return _PE._(-1, "malformed_error", null, jsonRepresentation);
    }
    final readableCode = _readableCodes[code] ?? "unknown";

    var serverMessage = jsonRepresentation["message"];
    if (serverMessage is! String) serverMessage = null;
    final data = jsonRepresentation["data"];

    return _PE._(code, readableCode, serverMessage as String?, data);
  }
}