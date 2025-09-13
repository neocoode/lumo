import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/authModels.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class AuthService {
  static String get _baseUrl => '${Environment.baseUrl}/api/auth';

  // Fazer requisição HTTP
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        default:
          throw ApiException('Método HTTP não suportado: $method', 400);
      }

      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          responseData['message'] ?? 'Erro na requisição',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('Sem conexão com a internet', 0);
    } on http.ClientException {
      throw ApiException('Erro de conexão', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e', 500);
    }
  }

  // Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/login',
        body: request.toJson(),
      );

      if (response['success'] == true) {
        return AuthResponse.fromJson(response['data']);
      } else {
        throw ApiException(
          response['message'] ?? 'Erro no login',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro no login: $e');
      }
      rethrow;
    }
  }

  // Registro
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/register',
        body: request.toJson(),
      );

      if (response['success'] == true) {
        return AuthResponse.fromJson(response['data']);
      } else {
        throw ApiException(
          response['message'] ?? 'Erro no registro',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro no registro: $e');
      }
      rethrow;
    }
  }

  // Logout
  Future<void> logout(String refreshToken) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/logout',
        body: {'refreshToken': refreshToken},
      );

      if (response['success'] != true) {
        throw ApiException(
          response['message'] ?? 'Erro no logout',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro no logout: $e');
      }
      rethrow;
    }
  }

  // Refresh Token
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/refresh',
        body: request.toJson(),
      );

      if (response['success'] == true) {
        return AuthResponse.fromJson(response['data']);
      } else {
        throw ApiException(
          response['message'] ?? 'Erro ao renovar token',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao renovar token: $e');
      }
      rethrow;
    }
  }

  // Esqueceu a senha
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/forgot-password',
        body: request.toJson(),
      );

      if (response['success'] != true) {
        throw ApiException(
          response['message'] ?? 'Erro ao enviar email de recuperação',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao enviar email de recuperação: $e');
      }
      rethrow;
    }
  }

  // Verificar token
  Future<User> verifyToken(String accessToken) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/verify',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response['success'] == true) {
        return User.fromJson(response['data']['user']);
      } else {
        throw ApiException(
          response['message'] ?? 'Token inválido',
          response['statusCode'] ?? 401,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao verificar token: $e');
      }
      rethrow;
    }
  }

  // Atualizar perfil
  Future<User> updateProfile(String accessToken, {String? name, String? photo}) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (photo != null) body['photo'] = photo;

      final response = await _makeRequest(
        'PUT',
        '/profile',
        body: body,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response['success'] == true) {
        return User.fromJson(response['data']);
      } else {
        throw ApiException(
          response['message'] ?? 'Erro ao atualizar perfil',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao atualizar perfil: $e');
      }
      rethrow;
    }
  }
}
