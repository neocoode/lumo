import 'package:flutter/material.dart';

// Enums
enum Categoria {
  geography,
  science,
  literature,
  history,
  mathematics,
  biology,
}

// Interfaces da API
class ISlideConfig {
  final int activeIndex;
  final int? selectedAnswer;

  ISlideConfig({
    required this.activeIndex,
    this.selectedAnswer,
  });

  bool get isAnswered => selectedAnswer != null;

  Map<String, dynamic> toJson() {
    return {
      'activeIndex': activeIndex,
      'selectedAnswer': selectedAnswer,
    };
  }

  factory ISlideConfig.fromJson(Map<String, dynamic> json) {
    return ISlideConfig(
      activeIndex: json['activeIndex'] ?? 0,
      selectedAnswer: json['selectedAnswer'],
    );
  }
}

class ISlideConfigs {
  final List<ISlideConfig> slides;
  final int totalCorrect;
  final int totalWrong;
  final int totalQuestions;
  final int totalAnswered;
  final double accuracyPercentage;

  ISlideConfigs({
    required this.slides,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalQuestions,
    required this.totalAnswered,
    required this.accuracyPercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'slides': slides.map((s) => s.toJson()).toList(),
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'totalQuestions': totalQuestions,
      'totalAnswered': totalAnswered,
      'accuracyPercentage': accuracyPercentage,
    };
  }

  factory ISlideConfigs.fromJson(Map<String, dynamic> json) {
    return ISlideConfigs(
      slides: (json['slides'] as List)
          .map((s) => ISlideConfig.fromJson(s))
          .toList(),
      totalCorrect: json['totalCorrect'] ?? 0,
      totalWrong: json['totalWrong'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      totalAnswered: json['totalAnswered'] ?? 0,
      accuracyPercentage: (json['accuracyPercentage'] ?? 0).toDouble(),
    );
  }
}

class ISlideQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final Categoria category;
  final String? imagePath;

  ISlideQuestion({
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

  factory ISlideQuestion.fromJson(Map<String, dynamic> json) {
    return ISlideQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
      category: _parseCategoria(json['category']),
      imagePath: json['imagePath'],
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

class ISlideData {
  final String backgroundImage;
  final String backgroundColor;
  final ISlideQuestion question;

  ISlideData({
    required this.backgroundImage,
    required this.backgroundColor,
    required this.question,
  });

  Color get backgroundColorColor {
    try {
      return Color(int.parse(backgroundColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF667eea); // Default color
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor,
      'question': question.toJson(),
    };
  }

  factory ISlideData.fromJson(Map<String, dynamic> json) {
    // A API retorna backgroundColor como um objeto {value: number, hex: string}
    String backgroundColor;
    if (json['backgroundColor'] is Map &&
        json['backgroundColor'].containsKey('hex')) {
      backgroundColor = json['backgroundColor']['hex'];
    } else {
      backgroundColor = json['backgroundColor']?.toString() ?? '#667eea';
    }

    return ISlideData(
      backgroundImage: json['backgroundImage'] ?? 'assets/images/default.svg',
      backgroundColor: backgroundColor,
      question: ISlideQuestion.fromJson(json['question']),
    );
  }
}

class ISlideCollectionDocument {
  final List<ISlideData> data;
  final ISlideConfigs configs;
  final List<String> categories;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ISlideCollectionDocument({
    required this.data,
    required this.configs,
    required this.categories,
    required this.title,
    required this.description,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((d) => d.toJson()).toList(),
      'configs': configs.toJson(),
      'categories': categories,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ISlideCollectionDocument.fromJson(Map<String, dynamic> json) {
    // A API retorna configs como um objeto com 'empty' e 'withAnswers'
    // Vamos usar 'empty' como configuração padrão
    Map<String, dynamic> configsData;
    if (json['configs'] is Map && json['configs'].containsKey('empty')) {
      configsData = json['configs']['empty'];
    } else {
      configsData = json['configs'];
    }

    return ISlideCollectionDocument(
      data: (json['data'] as List).map((d) => ISlideData.fromJson(d)).toList(),
      configs: ISlideConfigs.fromJson(configsData),
      categories: List<String>.from(json['categories'] ?? []),
      title: json['configs']['title'] ?? 'Quiz',
      description: json['configs']['description'] ?? 'Descrição do quiz',
      date: DateTime.parse(json['configs']['date'] ?? DateTime.now().toIso8601String()),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// Resposta da API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      statusCode: json['statusCode'],
    );
  }
}
