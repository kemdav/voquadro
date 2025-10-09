class AuthException implements Exception {
  /// The user-friendly message to be displayed in the UI.
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
