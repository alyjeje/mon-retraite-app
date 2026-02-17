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
    defaultValue: 'https://f298-2a01-cb08-10b6-3500-2173-7c5b-a060-ae24.ngrok-free.app',
  );

  /// Timeout pour les requetes HTTP
  static const Duration timeout = Duration(seconds: 30);
}
