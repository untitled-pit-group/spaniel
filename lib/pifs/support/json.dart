abstract class Jsonable {
  dynamic toJson();
}

abstract class JsonBuilder<T> {
  T fromJson(dynamic json);
}
