import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/apiModels.dart';

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
    
    // Se é uma lista de challenges (nova API)
    if (json is List) {
      print('📊 Lista de challenges recebida: ${json.length} items');
      
      final challenges = json.map((challengeJson) {
        return ChallengeItem(
          id: challengeJson['_id'] ?? challengeJson['id'] ?? '',
          title: challengeJson['configs']?['title'] ?? challengeJson['title'] ?? 'Challenge',
          description: challengeJson['configs']?['description'] ?? challengeJson['description'] ?? 'Descrição do challenge',
          category: _parseCategoria(challengeJson['categories']?[0] ?? 'geography'),
          questionCount: challengeJson['data']?.length ?? challengeJson['questionCount'] ?? 0,
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
      
      return ChallengesListResponse(
        challenges: challenges,
        total: challenges.length,
        categories: ['geography', 'science', 'literature', 'history', 'mathematics', 'biology'],
      );
    }
    
    // Se é um único objeto (formato antigo)
    if (json is Map<String, dynamic>) {
      // Verificar se é dados completos do banco (com configs) ou dados processados
      if (json.containsKey('configs') && json.containsKey('data')) {
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
        _baseUrl = baseUrl ?? Environment.apiUrl;

  // Listar dados do challenge (config)
  Future<ChallengesListResponse> getChallengesList() async {
    try {
      final response = await _makeRequest(
        'GET',
        '',
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
      return await _getFallbackChallengesList();
    }
  }

  // Fallback: converter dados completos para lista de challenges
  Future<ChallengesListResponse> _getFallbackChallengesList() async {
    try {
      final response = await _makeRequest(
        'GET',
        '',
      );

      if (response['success'] == true) {
        final fullData = ISlideCollectionDocument.fromJson(response['data']);
        print('📊 Dados completos recebidos no fallback: ${fullData.data.length} slides');
        
        // Converter cada slide para um challenge individual usando metadados do configs
        final challenges = fullData.data.asMap().entries.map((entry) {
          final index = entry.key;
          final slide = entry.value;
          final question = slide.question;
          
          return ChallengeItem(
            id: 'challenge_$index',
            title: fullData.title,
            description: fullData.description,
            category: question.category,
            questionCount: 1, // Cada slide tem 1 pergunta
            backgroundImage: slide.backgroundImage,
            backgroundColor: slide.backgroundColor,
            difficulty: 'Médio', // Valor padrão - deve vir do banco
            author: 'Sistema',
            createdAt: fullData.date,
            updatedAt: fullData.updatedAt ?? DateTime.now(),
            slideData: {
              'backgroundImage': slide.backgroundImage,
              'backgroundColor': slide.backgroundColor,
              'question': {
                'question': question.question,
                'options': question.options,
                'correctAnswer': question.correctAnswer,
                'explanation': question.explanation,
                'category': question.category.name,
                'imagePath': question.imagePath,
              }
            },
          );
        }).toList();

        print('📊 Challenges criados no fallback: ${challenges.length}');
        print('📊 Primeiro challenge: ${challenges.isNotEmpty ? challenges.first.title : 'Nenhum'}');
        
        return ChallengesListResponse(
          challenges: challenges,
          total: challenges.length,
          categories: fullData.categories,
        );
      } else {
        throw Exception('Erro ao buscar challenges: ${response['message']}');
      }
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
