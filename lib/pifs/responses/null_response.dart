/// This is a generic object to use for API calls that don't have bespoke response contents.
class PifsNullResponse {
  const PifsNullResponse();

  /// This will always return a [PifsNullResponse], even if the provided JSON
  /// had meaningful contents.
  factory PifsNullResponse.fromJson(dynamic json) => const PifsNullResponse();
}