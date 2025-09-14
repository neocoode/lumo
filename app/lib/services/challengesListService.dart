import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../config/environment.dart';
import '../models/apiModels.dart';
import '../stores/sessionStore.dart';

// Modelo para challenge individual (cada slide é um challenge)
class ChallengeItem {
  final String id;
  final String title;
  final String description;
  final Categoria category;
  final int questionCount;
  final String backgroundImage;
  final String backgroundColor;
  final String difficulty;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> slideData; // Dados originais do slide

  ChallengeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.questionCount,
    required this.backgroundImage,
    required this.backgroundColor,
    required this.difficulty,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.slideData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'questionCount': questionCount,
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor,
      'difficulty': difficulty,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'slideData': slideData,
    };
  }

  factory ChallengeItem.fromJson(Map<String, dynamic> json) {
    return ChallengeItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: _parseCategoria(json['category']),
      questionCount: json['questionCount'] ?? 0,
      backgroundImage: json['backgroundImage'] ?? 'assets/images/default.svg',
      backgroundColor: json['backgroundColor'] ?? '#667eea',
      difficulty: json['difficulty'] ?? 'Médio',
      author: json['author'] ?? 'Sistema',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      slideData: json['slideData'] ?? {},
    );
  }

  static Categoria _parseCategoria(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'geography':
        return Categoria.geography;
      case 'science':
        return Categoria.science;
      case 'literature':
        return Categoria.literature;
      case 'history':
        return Categoria.history;
      case 'mathematics':
        return Categoria.mathematics;
      case 'biology':
        return Categoria.biology;
      default:
        return Categoria.science;
    }
  }
}

// Resposta da API para dados do challenge
class ChallengesListResponse {
  final List<ChallengeItem> challenges;
  final int total;
  final List<String> categories;

  ChallengesListResponse({
    required this.challenges,
    required this.total,
    required this.categories,
  });

  factory ChallengesListResponse.fromJson(dynamic json) {
    print('📊 Processando JSON no fromJson: $json');
    print('📊 Tipo do JSON: ${json.runtimeType}');
    
    // Se é uma lista de challenges (nova API)
    if (json is List) {
      print('📊 Lista de challenges recebida: ${json.length} items');
      
      final challenges = json.map((challengeJson) {
        print('📊 Processando challenge: ${challengeJson['_id']} - ${challengeJson['configs']?['title']}');
        
        // Extrair categorias dos dados
        List<String> categories = ['geography']; // Default
        if (challengeJson['categories'] != null && challengeJson['categories'] is List) {
          try {
            categories = (challengeJson['categories'] as List).map<String>((c) => c.toString()).toList();
            print('📊 Categorias extraídas: $categories');
          } catch (e) {
            print('⚠️ Erro ao extrair categorias: $e');
            categories = ['geography'];
          }
        }
        
        return ChallengeItem(
          id: challengeJson['_id'] ?? challengeJson['id'] ?? '',
          title: challengeJson['configs']?['title'] ?? 'Challenge',
          description: challengeJson['configs']?['description'] ?? 'Descrição do challenge',
          category: _parseCategoria(categories.isNotEmpty ? categories[0] : 'geography'),
          questionCount: challengeJson['data']?.length ?? 0,
          backgroundImage: 'assets/images/default.svg',
          backgroundColor: '#667eea',
          difficulty: challengeJson['configs']?['difficulty'] ?? 'Médio',
          author: 'Sistema',
          createdAt: DateTime.parse(challengeJson['configs']?['date'] ?? challengeJson['createdAt'] ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(challengeJson['configs']?['updatedAt'] ?? challengeJson['updatedAt'] ?? DateTime.now().toIso8601String()),
          slideData: challengeJson,
        );
      }).toList();

      print('📊 ${challenges.length} challenges processados');
      print('📊 IDs dos challenges: ${challenges.map((c) => c.id).toList()}');
      
      return ChallengesListResponse(
        challenges: challenges,
        total: challenges.length,
        categories: ['geography', 'science', 'literature', 'history', 'mathematics', 'biology'],
      );
    }
    
    // Se é um único objeto (formato antigo)
    if (json is Map<String, dynamic>) {
      print('📊 Processando objeto único (formato antigo)');
      // Verificar se é dados completos do banco (com configs) ou dados processados
      if (json.containsKey('configs') && json.containsKey('data')) {
        print('📊 Dados completos do banco detectados');
      // Dados completos do banco - criar UM challenge que representa todo o conjunto
      final fullData = ISlideCollectionDocument.fromJson(json);
      print('📊 Dados completos recebidos: ${fullData.data.length} slides');
      
      // Criar UM challenge que representa todo o conjunto de slides
      final challenge = ChallengeItem(
        id: json['_id'] ?? 'challenge_main',
        title: fullData.title,
        description: fullData.description,
        category: _parseCategoria('geography'), // Categoria padrão para o challenge principal
        questionCount: fullData.data.length, // Total de perguntas
        backgroundImage: 'assets/images/default.svg',
        backgroundColor: '#667eea',
        difficulty: 'Médio',
        author: 'Sistema',
        createdAt: fullData.date,
        updatedAt: fullData.updatedAt ?? DateTime.now(),
        slideData: {
          'totalSlides': fullData.data.length,
          'categories': fullData.categories,
          'configs': {
            'totalQuestions': fullData.data.length,
            'totalCorrect': 0,
            'totalWrong': 0,
            'totalAnswered': 0,
            'accuracyPercent': 0,
          }
        },
      );

      print('📊 Challenge único criado: ${challenge.title} - ${challenge.questionCount} perguntas');
      
      return ChallengesListResponse(
        challenges: [challenge], // Apenas UM challenge
        total: 1, // Total de 1 challenge
        categories: fullData.categories,
      );
    } else {
      print('📊 Dados processados (formato antigo) detectados');
      // Dados processados (formato antigo) - manter compatibilidade
      final challenge = ChallengeItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        category: _parseCategoria('geography'), // Categoria padrão
        questionCount: json['questionCount'] ?? 0,
        backgroundImage: 'assets/images/default.svg',
        backgroundColor: '#667eea',
        difficulty: 'Médio',
        author: 'Sistema',
        createdAt: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
        slideData: {},
      );

      print('📊 Challenge criado (formato antigo): ${challenge.title} - ${challenge.questionCount} perguntas');
      
      return ChallengesListResponse(
        challenges: [challenge],
        total: 1,
        categories: List<String>.from(json['categories'] ?? []),
      );
      }
    }
    
    // Fallback
    print('📊 Fallback: nenhum formato reconhecido');
    print('📊 JSON recebido: $json');
    return ChallengesListResponse(
      challenges: [],
      total: 0,
      categories: [],
    );
  }

  static Categoria _parseCategoria(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'geography':
        return Categoria.geography;
      case 'science':
        return Categoria.science;
      case 'literature':
        return Categoria.literature;
      case 'history':
        return Categoria.history;
      case 'mathematics':
        return Categoria.mathematics;
      case 'biology':
        return Categoria.biology;
      default:
        return Categoria.science;
    }
  }
}

class ChallengesListService {
  final http.Client _client;
  final String _baseUrl;

  ChallengesListService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Environment.challengesEndpoint;

  // Listar dados do challenge (config)
  Future<ChallengesListResponse> getChallengesList([BuildContext? context]) async {
    try {
      final response = await _makeRequest(
        'GET',
        '',
        context: context,
      );

      if (response['success'] == true) {
        print('📊 Dados recebidos da API: ${response['data']}');
        final result = ChallengesListResponse.fromJson(response['data']);
        print('📊 Challenges processados: ${result.challenges.length}');
        print('📊 Total: ${result.total}');
        return result;
      } else {
        throw Exception('Erro ao buscar challenges: ${response['message']}');
      }
    } catch (e) {
      print('Erro ao buscar lista de challenges: $e');
      // Fallback: converter dados completos para lista de challenges
      return await _getFallbackChallengesList(context);
    }
  }

  // Fallback: converter dados completos para lista de challenges
  Future<ChallengesListResponse> _getFallbackChallengesList([BuildContext? context]) async {
    try {
      // No fallback, vamos retornar uma lista vazia em vez de fazer outra requisição
      print('📊 Fallback: retornando lista vazia');
      return ChallengesListResponse(
        challenges: [],
        total: 0,
        categories: [],
      );
    } catch (e) {
      print('Erro no fallback: $e');
      return ChallengesListResponse(
        challenges: [],
        total: 0,
        categories: [],
      );
    }
  }



  // Método privado para fazer requisições
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    BuildContext? context,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    print('🌐 Fazendo requisição: $method $_baseUrl$endpoint');
    
    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await _client.get(
          uri,
          headers: _getHeaders(context),
        );
        break;
      case 'POST':
        response = await _client.post(
          uri,
          headers: _getHeaders(context),
          body: body != null ? json.encode(body) : null,
        );
        break;
      default:
        throw Exception('Método HTTP não suportado: $method');
    }

    print('📡 Resposta recebida: ${response.statusCode}');
    print('📡 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedResponse = json.decode(response.body);
      print('📡 Resposta decodificada: $decodedResponse');
      return decodedResponse;
    } else {
      throw HttpException(
        'Erro HTTP ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  }

  // Headers padrão
  Map<String, String> _getHeaders([BuildContext? context]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Adicionar token de autenticação se disponível
    if (context != null) {
      try {
        final sessionStore = Provider.of<SessionStore>(context, listen: false);
        final accessToken = sessionStore.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $accessToken';
        }
      } catch (e) {
        print('Erro ao obter token de autenticação: $e');
      }
    }

    return headers;
  }

  // Fechar cliente HTTP
  void dispose() {
    _client.close();
  }
}
