import "package:spaniel/pifs/support/json.dart";

/// This is a generic object to use for API calls that don't have bespoke response contents.
class PifsNullResponse {}

/// This builder will always returns a [PifsNullResponse], even if the provided JSON had meaningful contents.
class PifsNullResponseBuilder implements JsonBuilder<PifsNullResponse> {
  @override
  PifsNullResponse fromJson(json) {
    return PifsNullResponse();
  }
}