abstract class Jsonable {
  dynamic toJson();
}

/// Thrown from a [fromJson] method in case the JSON representation returned from
/// the server is invalid for deserialization at the specified key.
class JsonRepresentationException implements Exception {
  final dynamic source;

  /// [null] if [source] was of an invalid shape in general.
  final String? key;

  /// The received map has an invalid value at [key].
  // yes mom i know what i'm doing with the deliberately typed parameter
  // ignore: unnecessary_this, prefer_initializing_formals
  JsonRepresentationException.invalidAtKey(this.source, String key) : this.key = key;

  /// The received value was expected to be of a certain shape (map, list etc.)
  /// but wasn't. Sets [key] to [null].
  JsonRepresentationException.invalidShape(this.source) : key = null;

  @override
  String toString() => "Invalid JSON representation received from server" +
    (key == null ? " (at $key)" : "");
}
typedef _JRE = JsonRepresentationException;

/// A wrapper around a JSON map type that generically verifies preconditions on
/// its structure, automatically throwing a [JsonRepresentationException] if they
/// aren't met.
class Unjsoner {
  final Map<String, dynamic> inner;
  Unjsoner(this.inner);

  /// Ensure that the value at [key] is present and is of type [T]. Throws a
  /// [JsonRepresentationException] otherwise.
  T v<T>(String key) {
    final value = inner[key];
    if (value is! T) throw _JRE.invalidAtKey(inner, key);
    return value;
  }

  /// Ensure that the value at [key] is present, of type [T], and passes the
  /// provided validation function. Throws a [JsonRepresentationException]
  /// otherwise.
  T val<T>(String key, bool Function(T) validator) {
    final value = inner[key];
    if (value is! T) throw _JRE.invalidAtKey(inner, key);
    if (!validator(value)) throw _JRE.invalidAtKey(inner, key);
    return value;
  }

  /// Ensure that the value at [key] is present, of type [Base], and attempt
  /// transforming it with the provided [map] function into type [Transform]. If
  /// the function returns [null], the value is presumed to be of invalid format.
  /// Throws a [JsonRepresentationException] on failure.
  Transform vt<Base, Transform>(String key, Transform? Function(Base) map) {
    final value = inner[key];
    if (value is! Base) throw _JRE.invalidAtKey(inner, key);
    final transform = map(value);
    if (transform == null) throw _JRE.invalidAtKey(inner, key);
    return transform;
  }

  /// Ensure that the value at [key], if present, is of type [T]. Returns null
  /// if there is no value at [key]; if the value is present but of the wrong
  /// type, throws a [JsonRepresentationException].
  T? opt<T>(String key) {
    final value = inner[key];
    if (value == null) return null;
    if (value is! T) throw _JRE.invalidAtKey(inner, key);
    return value;
  }

  /// Similar to [vt], but returns [null] iff the key isn't present or is [null].
  /// The transformer will be invoked if the value at [key] isn't [null]; if the
  /// transformer itself returns [null], a [JsonRepresentationException] will be
  /// thrown.
  Transform? vtOpt<Base, Transform>(String key, Transform? Function(Base) map) {
    final value = inner[key];
    if (value == null) return null;
    if (value is! Base) throw _JRE.invalidAtKey(inner, key);
    final transform = map(value!);
    if (transform == null) throw _JRE.invalidAtKey(inner, key);
    return transform;
  }

  /// Ensure that the value at [key] is a list whose every element is of type
  /// [T]. This check is stricter than simply casting [List<dynamic>] to the
  /// necessary concretely-typed list. Throws a [JsonRepresentationException] if
  /// the key is absent, is not a list, or any of its elements are not of type [T].
  List<T> list<T>(String key) {
    final list = inner[key];
    if (list is! List<dynamic>) throw _JRE.invalidAtKey(inner, key);
    return list.map((item) {
      if (item is T) {
        return item;
      } else {
        throw _JRE.invalidAtKey(inner, key);
      }
    }).toList(growable: false);
  }
}