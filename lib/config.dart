class Config {
  /// The Foxhound endpoint to refer to.
  /// The value is taken from a FX_ENDPOINT variable passed to --dart-define
  static const fxEndpoint = String.fromEnvironment("FX_ENDPOINT", defaultValue: "http://foxhound.localhost");
  
  /// The secret key used by Foxhound.
  /// The value is taken from a FX_KEY variable passed to --dart-define
  static const fxSecretKey = String.fromEnvironment("FX_KEY", defaultValue: "hackme");
}