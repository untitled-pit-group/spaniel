class PifsStringResponse {
  final String response;
  const PifsStringResponse(this.response);

  /// This will always return a [PifsStringResponse], even if the provided JSON
  /// had meaningful contents.
  factory PifsStringResponse.fromJson(dynamic json) {
    return PifsStringResponse(json);
  }
}