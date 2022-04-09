import 'package:dartz/dartz.dart';

extension Unwrap<T> on Option<T> {
  T? get optional => fold(() => null, (x) => x);
  T get unwrapped => (this as Some<T>).value;
}