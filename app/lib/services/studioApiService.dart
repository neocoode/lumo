import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/studioModels.dart';

class StudioApiService {
  final http.Client _client;
  final String _baseUrl;

  StudioApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Environment.apiUrl;

  // Salvar quiz
  Future<bool> saveQuiz(StudioQuiz quiz) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/api/studio/save',
        body: quiz.toJson(),
      );

      return response['success'] == true;
    } catch (e) {
      print('Erro ao salvar quiz: $e');
      return false;
    }
  }

  // Listar meus quizzes
  Future<List<StudioQuiz>> getMyQuizzes() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/api/studio/list',
      );

      if (response['success'] == true) {
        final List<dynamic> quizzesJson = response['data'] ?? [];
        return quizzesJson
            .map((json) => StudioQuiz.fromJson(json))
            .toList();
      } else {
        throw Exception('Erro ao carregar quizzes: ${response['message']}');
      }
    } catch (e) {
      print('Erro ao carregar quizzes: $e');
      return [];
    }
  }

  // Deletar quiz
  Future<bool> deleteQuiz(String quizId) async {
    try {
      final response = await _makeRequest(
        'DELETE',
        '/api/studio/delete/$quizId',
      );

      return response['success'] == true;
    } catch (e) {
      print('Erro ao deletar quiz: $e');
      return false;
    }
  }

  // Atualizar quiz
  Future<bool> updateQuiz(StudioQuiz quiz) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/api/studio/update/${quiz.id}',
        body: quiz.toJson(),
      );

      return response['success'] == true;
    } catch (e) {
      print('Erro ao atualizar quiz: $e');
      return false;
    }
  }

  // Obter quiz por ID
  Future<StudioQuiz?> getQuizById(String quizId) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/api/studio/quiz/$quizId',
      );

      if (response['success'] == true) {
        return StudioQuiz.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter quiz: $e');
      return null;
    }
  }

  // Obter estatísticas do usuário
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/api/studio/stats',
      );

      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Erro ao obter estatísticas: $e');
      return {};
    }
  }

  // Método privado para fazer requisições
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    
    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await _client.get(
          uri,
          headers: _getHeaders(),
        );
        break;
      case 'POST':
        response = await _client.post(
          uri,
          headers: _getHeaders(),
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await _client.put(
          uri,
          headers: _getHeaders(),
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await _client.delete(
          uri,
          headers: _getHeaders(),
        );
        break;
      default:
        throw Exception('Método HTTP não suportado: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw HttpException(
        'Erro HTTP ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  }

  // Headers padrão
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Fechar cliente HTTP
  void dispose() {
    _client.close();
  }
}
