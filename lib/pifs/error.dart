import 'package:collection/collection.dart';

typedef _PE = PifsError; // Shorthand

/// Enum like class that stores all known PIFS errors, and can retrieve
/// an error by code.
class PifsError {
  final String readableCode;
  final int code;

  // Prevent constructing from outside
  const PifsError._(this.code, this.readableCode);

  static const values = [
    _PE._(-32602, "invalid_params"),
    _PE._(1000, "size_limit_exceeded"),
    _PE._(1001, "in_progress"),
    _PE._(2409, "conflict"),
    _PE._(2404, "not_found"),
  ];

  static _PE fromCode(int code) => values.firstWhere(
    (e) => e.code == code,
    orElse: () => const _PE._(-1, "unknown")
  );
}