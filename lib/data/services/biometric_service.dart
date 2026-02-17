import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Service biometrique : Face ID / Touch ID + stockage securise des credentials.
class BiometricService {
  static const _keyIdentifiant = 'bio_identifiant';
  static const _keyMotDePasse = 'bio_mot_de_passe';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Verifie si le device supporte la biometrie
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('[BiometricService] isAvailable error: $e');
      return false;
    }
  }

  /// Verifie si des credentials biometriques sont sauvegardes
  Future<bool> hasStoredCredentials() async {
    final id = await _secureStorage.read(key: _keyIdentifiant);
    return id != null && id.isNotEmpty;
  }

  /// Recupere l'identifiant sauvegarde (pour afficher quel compte)
  Future<String?> getStoredIdentifiant() async {
    return await _secureStorage.read(key: _keyIdentifiant);
  }

  /// Sauvegarde les credentials dans le stockage securise (chiffre par l'OS)
  Future<void> saveCredentials(String identifiant, String motDePasse) async {
    await _secureStorage.write(key: _keyIdentifiant, value: identifiant);
    await _secureStorage.write(key: _keyMotDePasse, value: motDePasse);
  }

  /// Recupere les credentials sauvegardes
  Future<({String identifiant, String motDePasse})?> getCredentials() async {
    final id = await _secureStorage.read(key: _keyIdentifiant);
    final pwd = await _secureStorage.read(key: _keyMotDePasse);
    if (id != null && pwd != null) {
      return (identifiant: id, motDePasse: pwd);
    }
    return null;
  }

  /// Efface les credentials biometriques
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyIdentifiant);
    await _secureStorage.delete(key: _keyMotDePasse);
  }

  /// Lance l'authentification biometrique (Face ID / Touch ID)
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Identifiez-vous pour acceder a votre espace retraite',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('[BiometricService] authenticate error: $e');
      return false;
    }
  }
}
