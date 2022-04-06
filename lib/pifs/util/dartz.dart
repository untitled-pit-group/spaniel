import "package:dartz/dartz.dart";

extension Unwrap<T> on Option<T> {
  T get unwrapped {
    late T val;
    fold(
      () => StateError("Tried to unwrap a non-Some Option"),
      (t) => val = t,
    );
    return val;
  }

  T? get optional => fold(() => null, (t) => t);
}