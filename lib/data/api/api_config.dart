/// Configuration de l'API BFF.
///
/// Lancement sur simulateur (localhost) :
///   flutter run
///
/// Lancement sur device physique (HTTPS via ngrok) :
///   flutter run --dart-define=BFF_URL=https://xxxx.ngrok-free.app
///
/// Production :
///   flutter run --dart-define=BFF_URL=https://bff.groupama.fr
class ApiConfig {
  ApiConfig._();

  /// URL de base du BFF.
  static const String baseUrl = String.fromEnvironment(
    'BFF_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Timeout pour les requetes HTTP
  static const Duration timeout = Duration(seconds: 30);
}
