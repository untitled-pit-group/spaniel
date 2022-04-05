import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/fakes/fake_client.dart";
import "package:spaniel/pifs/support/flutter.dart";

enum PifsOfflineReason {
  /// The API secret key was deemed invalid by the server. This cannot be fixed
  /// without reconfiguration. Reconnection will not be attempted.
  badSecret,

  /// The client device is currently offline. The connection will be retried
  /// eventually. Note that this can later change to [badSecret] when the secret
  /// can become checked.
  networkConnection,
}

/// A fake client that's used only when a real client cannot be instantiated. If
/// the concrete type of a given instance of [PifsClient] is [PifsOfflineClient],
/// it should be assumed that no operation can be performed with the backend at
/// the given time. Nonetheless, over the time a particular widget is mounted,
/// this assumption might change, so the check for [PifsOfflineClient] should be
/// performed only after a user initiates some action.
class PifsOfflineClient extends PifsFakeClient {
  /// An explanation of why the client is considered to be offline.
  final PifsOfflineReason reason;

  const PifsOfflineClient(this.reason);
}

/// A fake client that's substituted by [PifsClientProvider] while attempting
/// connection to the backend. The [Future] provided herein should be waited upon,
/// after which time the instance of [PifsIndeterminateClient] will have been
/// replaced either with a concrete connection or a [PifsOfflineClient].
class PifsIndeterminateClient extends PifsFakeClient {
  Future<PifsClient> connected;
  PifsIndeterminateClient(this.connected);
}