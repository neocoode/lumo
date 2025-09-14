import 'apiModels.dart';

// Modelo para configurações específicas do slide
class StudioSlideConfig {
  final int slideTime;
  final bool allowSkip;
  final bool showExplanation;
  final String difficulty;
  final String backgroundImage;
  final Map<String, dynamic> backgroundColor;

  StudioSlideConfig({
    this.slideTime = 30,
    this.allowSkip = true,
    this.showExplanation = true,
    this.difficulty = 'medium',
    this.backgroundImage = 'assets/images/default.svg',
    this.backgroundColor = const {'hex': '#667eea', 'value': 0x667eea},
  });

  Map<String, dynamic> toJson() {
    return {
      'slideTime': slideTime,
      'allowSkip': allowSkip,
      'showExplanation': showExplanation,
      'difficulty': difficulty,
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor,
    };
  }

  factory StudioSlideConfig.fromJson(Map<String, dynamic> json) {
    return StudioSlideConfig(
      slideTime: json['slideTime'] ?? 30,
      allowSkip: json['allowSkip'] ?? true,
      showExplanation: json['showExplanation'] ?? true,
      difficulty: json['difficulty'] ?? 'medium',
      backgroundImage: json['backgroundImage'] ?? 'assets/images/default.svg',
      backgroundColor: Map<String, dynamic>.from(json['backgroundColor'] ?? {'hex': '#667eea', 'value': 0x667eea}),
    );
  }
}

// Modelo para dados da pergunta
class StudioQuestionData {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final Categoria category;
  final String? imagePath;

  StudioQuestionData({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category.name,
      'imagePath': imagePath,
    };
  }

  factory StudioQuestionData.fromJson(Map<String, dynamic> json) {
    return StudioQuestionData(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
      category: parseCategoria(json['category']),
      imagePath: json['imagePath'],
    );
  }
}

// Modelo para uma pergunta personalizada (slide completo)
class StudioQuestion {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Dados e configurações do slide
  final StudioSlideConfig configs;
  final StudioQuestionData data;

  StudioQuestion({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.configs,
    required this.data,
  });

  // Getters para compatibilidade com código existente
  String get question => data.question;
  List<String> get options => data.options;
  int get correctAnswer => data.correctAnswer;
  String get explanation => data.explanation;
  Categoria get category => data.category;
  String? get imagePath => data.imagePath;
  int get slideTime => configs.slideTime;
  bool get allowSkip => configs.allowSkip;
  bool get showExplanation => configs.showExplanation;
  String get difficulty => configs.difficulty;

  bool get isValid {
    return data.question.isNotEmpty &&
           data.options.where((option) => option.isNotEmpty).length >= 2 && // Pelo menos 2 opções preenchidas
           data.explanation.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'configs': configs.toJson(),
      'data': data.toJson(),
    };
  }

  factory StudioQuestion.fromJson(Map<String, dynamic> json) {
    return StudioQuestion(
      id: json['id'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      configs: StudioSlideConfig.fromJson(json['configs'] ?? {}),
      data: StudioQuestionData.fromJson(json['data'] ?? {}),
    );
  }

  StudioQuestion copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    StudioSlideConfig? configs,
    StudioQuestionData? data,
  }) {
    return StudioQuestion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      configs: configs ?? this.configs,
      data: data ?? this.data,
    );
  }
}

// Modelo para configurações do quiz
class StudioQuizConfig {
  final String title;
  final String description;
  final String backgroundColor;
  final String backgroundImage;
  final int timePerQuestion; // em segundos, 0 = sem tempo
  final bool showExplanation;
  final bool shuffleQuestions;
  final bool shuffleOptions;

  StudioQuizConfig({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.backgroundImage,
    this.timePerQuestion = 0,
    this.showExplanation = true,
    this.shuffleQuestions = false,
    this.shuffleOptions = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'backgroundColor': backgroundColor,
      'backgroundImage': backgroundImage,
      'timePerQuestion': timePerQuestion,
      'showExplanation': showExplanation,
      'shuffleQuestions': shuffleQuestions,
      'shuffleOptions': shuffleOptions,
    };
  }

  factory StudioQuizConfig.fromJson(Map<String, dynamic> json) {
    return StudioQuizConfig(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      backgroundColor: json['backgroundColor'] ?? '#667eea',
      backgroundImage: json['backgroundImage'] ?? 'assets/images/default.svg',
      timePerQuestion: json['timePerQuestion'] ?? 0,
      showExplanation: json['showExplanation'] ?? true,
      shuffleQuestions: json['shuffleQuestions'] ?? false,
      shuffleOptions: json['shuffleOptions'] ?? false,
    );
  }
}

// Modelo para o quiz completo do Studio
class StudioQuiz {
  final String id;
  final String title;
  final String description;
  final List<StudioQuestion> questions;
  final StudioQuizConfig config;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudioQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'config': config.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StudioQuiz.fromJson(Map<String, dynamic> json) {
    return StudioQuiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => StudioQuestion.fromJson(q))
          .toList() ?? [],
      config: StudioQuizConfig.fromJson(json['config'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Modelo para resposta da API do Studio
class StudioApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  StudioApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory StudioApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return StudioApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      statusCode: json['statusCode'],
    );
  }
}

// Função auxiliar para parsing de categoria
Categoria parseCategoria(String categoryString) {
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