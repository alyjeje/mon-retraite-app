import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class AuthResult {
  final bool success;
  final String? token;
  final String? error;
  final String? message;
  final int? statutConnexion;
  final int? inactivityTimeoutMinutes;

  AuthResult({
    required this.success,
    this.token,
    this.error,
    this.message,
    this.statutConnexion,
    this.inactivityTimeoutMinutes,
  });
}

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<AuthResult> login(String identifiant, String motDePasse) async {
    try {
      final data = await _api.post(ApiEndpoints.login, body: {
        'identifiant': identifiant,
        'motDePasse': motDePasse,
      });

      if (data['success'] == true) {
        _api.setToken(data['token']);
        return AuthResult(
          success: true,
          token: data['token'],
          inactivityTimeoutMinutes: data['inactivityTimeoutMinutes'] as int?,
        );
      }

      return AuthResult(
        success: false,
        error: data['error'],
        message: data['message'],
        statutConnexion: data['statutConnexion'],
      );
    } on ApiException catch (e) {
      // 401 = credentials incorrects (reponse structuree du BFF)
      if (e.statusCode == 401) {
        return AuthResult(success: false, error: e.error, message: e.message);
      }
      return AuthResult(
        success: false,
        error: 'network_error',
        message: 'Impossible de se connecter au serveur. Verifiez votre connexion.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'network_error',
        message: 'Impossible de se connecter au serveur. Verifiez votre connexion.',
      );
    }
  }

  Future<bool> refresh() async {
    try {
      final data = await _api.post(ApiEndpoints.refresh);
      if (data['success'] == true) {
        _api.setToken(data['token']);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Ignore errors - we're logging out anyway
    }
    _api.clearToken();
  }
}
