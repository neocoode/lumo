import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/apiModels.dart';

abstract class ISlidesApiService {
  Future<ISlideCollectionDocument> getSlides();
  Future<List<String>> getCategories();
  Future<List<ISlideData>> getSlidesByCategory(String category);
  Future<ISlideData?> getSlideByIndex(int index);
  Future<ISlideConfigs> getConfigsEmpty();
  Future<ISlideConfigs> getConfigsWithAnswers();
  Future<bool> updateSlideAnswer(int index, int answer);
  Future<Map<String, dynamic>> getStats();
}

class SlidesApiService implements ISlidesApiService {
  final http.Client _client;
  final String _baseUrl;

  SlidesApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Environment.apiUrl;

  @override
  Future<ISlideCollectionDocument> getSlides() async {
    try {
      final response = await _makeRequest(
        'GET',
        Environment.slidesEndpoint,
      );

      if (response['success'] == true) {
        return ISlideCollectionDocument.fromJson(response['data']);
      } else {
        throw ApiException(
          'Erro ao buscar slides: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao buscar slides: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _makeRequest(
        'GET',
        Environment.categoriesEndpoint,
      );

      if (response['success'] == true) {
        return List<String>.from(response['data'] ?? []);
      } else {
        throw ApiException(
          'Erro ao buscar categorias: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao buscar categorias: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<ISlideData>> getSlidesByCategory(String category) async {
    try {
      final response = await _makeRequest(
        'GET',
        '${Environment.categoryEndpoint}/$category',
      );

      if (response['success'] == true) {
        return (response['data'] as List)
            .map((slide) => ISlideData.fromJson(slide))
            .toList();
      } else {
        throw ApiException(
          'Erro ao buscar slides por categoria: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao buscar slides por categoria: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ISlideData?> getSlideByIndex(int index) async {
    try {
      final response = await _makeRequest(
        'GET',
        '${Environment.slideEndpoint}/$index',
      );

      if (response['success'] == true) {
        return ISlideData.fromJson(response['data']);
      } else {
        throw ApiException(
          'Erro ao buscar slide: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao buscar slide: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ISlideConfigs> getConfigsEmpty() async {
    try {
      final response = await _makeRequest(
        'GET',
        Environment.configsEmptyEndpoint,
      );

      if (response['success'] == true) {
        return ISlideConfigs.fromJson(response['data']);
      } else {
        throw ApiException(
          'Erro ao buscar configurações vazias: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao buscar configurações vazias: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ISlideConfigs> getConfigsWithAnswers() async {
    try {
      final response = await _makeRequest(
        'GET',
        Environment.configsWithAnswersEndpoint,
      );

      if (response['success'] == true) {
        return ISlideConfigs.fromJson(response['data']);
      } else {
        throw ApiException(
          'Erro ao buscar configurações com respostas: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao buscar configurações com respostas: $e');
      }
      rethrow;
    }
  }

  @override
  Future<bool> updateSlideAnswer(int index, int answer) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '${Environment.slideEndpoint}/$index/answer',
        body: {'answer': answer},
      );

      if (response['success'] == true) {
        return true;
      } else {
        throw ApiException(
          'Erro ao atualizar resposta: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao atualizar resposta: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _makeRequest(
        'GET',
        Environment.statsEndpoint,
      );

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw ApiException(
          'Erro ao buscar estatísticas: ${response['message']}',
          response['statusCode'] ?? 500,
        );
      }
    } catch (e) {
      if (Environment.enableLogging) {
        print('Erro ao buscar estatísticas: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    int retries = 0;

    while (retries < Environment.maxRetries) {
      try {
        final uri = Uri.parse(endpoint);
        http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client
                .get(uri, headers: Environment.defaultHeaders)
                .timeout(Environment.receiveTimeout);
            break;
          case 'POST':
            response = await _client
                .post(
                  uri,
                  headers: Environment.defaultHeaders,
                  body: body != null ? json.encode(body) : null,
                )
                .timeout(Environment.receiveTimeout);
            break;
          case 'PUT':
            response = await _client
                .put(
                  uri,
                  headers: Environment.defaultHeaders,
                  body: body != null ? json.encode(body) : null,
                )
                .timeout(Environment.receiveTimeout);
            break;
          case 'DELETE':
            response = await _client
                .delete(uri, headers: Environment.defaultHeaders)
                .timeout(Environment.receiveTimeout);
            break;
          default:
            throw ArgumentError('Método HTTP não suportado: $method');
        }

        if (Environment.enableApiLogging) {
          print('API Request: $method $endpoint');
          print('API Response: ${response.statusCode}');
        }

        final responseData = json.decode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return responseData;
        } else {
          throw ApiException(
            'Erro HTTP ${response.statusCode}: ${responseData['message'] ?? 'Erro desconhecido'}',
            response.statusCode,
          );
        }
      } on SocketException {
        if (retries < Environment.maxRetries - 1) {
          if (Environment.enableLogging) {
            print(
                'Erro de conexão, tentando novamente... (${retries + 1}/${Environment.maxRetries})');
          }
          await Future.delayed(Environment.retryDelay);
          retries++;
          continue;
        } else {
          throw ApiException('Erro de conexão com a API', 0);
        }
      } on HttpException catch (e) {
        throw ApiException('Erro HTTP: ${e.message}', 0);
      } catch (e) {
        if (retries < Environment.maxRetries - 1) {
          if (Environment.enableLogging) {
            print(
                'Erro na requisição, tentando novamente... (${retries + 1}/${Environment.maxRetries})');
          }
          await Future.delayed(Environment.retryDelay);
          retries++;
          continue;
        } else {
          rethrow;
        }
      }
    }

    throw ApiException('Número máximo de tentativas excedido', 0);
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
