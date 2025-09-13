import 'package:flutter/material.dart';
import 'apiModels.dart';

// Modelo para uma pergunta personalizada
class StudioQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final Categoria category;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudioQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category.name,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StudioQuestion.fromJson(Map<String, dynamic> json) {
    return StudioQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
      category: _parseCategoria(json['category']),
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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

  StudioQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    Categoria? category,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudioQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  StudioQuizConfig copyWith({
    String? title,
    String? description,
    String? backgroundColor,
    String? backgroundImage,
    int? timePerQuestion,
    bool? showExplanation,
    bool? shuffleQuestions,
    bool? shuffleOptions,
  }) {
    return StudioQuizConfig(
      title: title ?? this.title,
      description: description ?? this.description,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      showExplanation: showExplanation ?? this.showExplanation,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
    );
  }
}

// Modelo para um quiz completo
class StudioQuiz {
  final String id;
  final String title;
  final String description;
  final List<StudioQuestion> questions;
  final StudioQuizConfig config;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId; // ID do usuário que criou

  StudioQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
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
      'authorId': authorId,
    };
  }

  factory StudioQuiz.fromJson(Map<String, dynamic> json) {
    return StudioQuiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List)
          .map((q) => StudioQuestion.fromJson(q))
          .toList(),
      config: StudioQuizConfig.fromJson(json['config'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      authorId: json['authorId'] ?? '',
    );
  }

  StudioQuiz copyWith({
    String? id,
    String? title,
    String? description,
    List<StudioQuestion>? questions,
    StudioQuizConfig? config,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
  }) {
    return StudioQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
    );
  }

}

// Estado do processo de criação
enum StudioCreationStep {
  config,
  questions,
  review,
  save,
}

// Resposta da API do Studio
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
