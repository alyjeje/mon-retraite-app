import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Exception API personnalisee
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? error;

  ApiException({required this.statusCode, required this.message, this.error});

  @override
  String toString() => 'ApiException($statusCode): $message';

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}

/// Client HTTP centralise pour communiquer avec le BFF.
/// Gere le token, les headers, les erreurs.
class ApiClient {
  final http.Client _client = http.Client();
  String? _token;

  /// Token BFF actuel
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  /// Met a jour le token apres login
  void setToken(String token) {
    _token = token;
  }

  /// Supprime le token (deconnexion)
  void clearToken() {
    _token = null;
  }

  /// Headers communs
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Evite la page interstitielle ngrok en dev
      'ngrok-skip-browser-warning': 'true',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// URL complete
  Uri _uri(String path, {Map<String, String>? queryParams}) {
    final base = ApiConfig.baseUrl;
    final uri = Uri.parse('$base$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// GET
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = _uri(path, queryParams: queryParams);
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  /// POST
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = _uri(path);
    final response = await _client
        .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  /// PUT
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = _uri(path);
    final response = await _client
        .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  /// Traitement de la reponse
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    // Erreur
    String message = 'Erreur inattendue';
    String? error;
    try {
      final body = jsonDecode(response.body);
      message = body['message'] ?? message;
      error = body['error'];
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : message;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      error: error,
    );
  }

  /// Fermer le client
  void dispose() {
    _client.close();
  }
}
