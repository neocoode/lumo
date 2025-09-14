import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/apiModels.dart';
import '../models/studioModels.dart';
import '../services/challengesListService.dart';
import '../services/studioApiService.dart';

class StudioStore extends ChangeNotifier {
  // Estados do store
  bool _isLoading = false;
  String? _error;
  ChallengeItem? _currentChallenge;
  List<StudioStep> _steps = [];
  int _currentStepIndex = 0;
  bool _isEditing = false;
  
  // Dados do challenge sendo criado/editado
  String _title = '';
  String _description = '';
  String _category = 'geography';
  List<StudioQuestion> _questions = [];
  
  // Configurações do challenge
  int _slideTime = 30;
  int _totalTime = 300;
  bool _allowSkip = true;
  bool _showExplanation = true;
  bool _randomizeQuestions = false;
  String _difficulty = 'medium';
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChallengeItem? get currentChallenge => _currentChallenge;
  List<StudioStep> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  StudioStep? get currentStep => _steps.isNotEmpty ? _steps[_currentStepIndex] : null;
  bool get isEditing => _isEditing;
  bool get isCreating => !_isEditing;
  
  // Dados do challenge
  String get title => _title;
  String get description => _description;
  String get category => _category;
  List<StudioQuestion> get questions => _questions;
  
  // Configurações do challenge
  int get slideTime => _slideTime;
  int get totalTime => _totalTime;
  bool get allowSkip => _allowSkip;
  bool get showExplanation => _showExplanation;
  bool get randomizeQuestions => _randomizeQuestions;
  String get difficulty => _difficulty;
  
  // Validações
  bool get canProceedToNextStep {
    switch (_currentStepIndex) {
      case 0: // Configurações básicas
        return _title.isNotEmpty && _description.isNotEmpty;
      case 1: // Perguntas
        return _questions.isNotEmpty && _questions.every((q) => q.isValid);
      case 2: // Revisão
        return true;
      default:
        return false;
    }
  }
  
  bool get canSaveChallenge {
    return _title.isNotEmpty && 
           _description.isNotEmpty && 
           _questions.isNotEmpty && 
           _questions.every((q) => q.isValid);
  }

  StudioStore() {
    _initializeSteps();
    startNewChallenge(); // Inicializar para criação por padrão
  }

  void _initializeSteps() {
    _steps = [
      StudioStep(
        id: 'basic_config',
        title: 'Configurações Básicas',
        description: 'Defina o título, descrição e categoria do challenge',
        icon: Icons.settings_rounded,
      ),
      StudioStep(
        id: 'questions',
        title: 'Perguntas',
        description: 'Adicione e configure as perguntas do challenge',
        icon: Icons.quiz_rounded,
      ),
      StudioStep(
        id: 'review',
        title: 'Revisão',
        description: 'Revise e finalize seu challenge',
        icon: Icons.check_circle_rounded,
      ),
    ];
  }

  // Carregar challenge para edição
  Future<void> loadChallengeForEdit(ChallengeItem challenge) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Carregar dados básicos do challenge
      _currentChallenge = challenge;
      _title = challenge.title;
      _description = challenge.description;
      _category = challenge.category.name;
      
      // TODO: Carregar perguntas e configurações do challenge via API
      // Por enquanto, usar dados de exemplo
      _questions = _generateSampleQuestions();
      
      // Configurações padrão para edição (serão carregadas da API futuramente)
      _slideTime = 30;
      _totalTime = 300;
      _allowSkip = true;
      _showExplanation = true;
      _randomizeQuestions = false;
      _difficulty = 'medium';
      
      _isEditing = true;
      _currentStepIndex = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar challenge: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Iniciar criação de novo challenge
  void startNewChallenge() {
    _currentChallenge = null;
    _title = '';
    _description = '';
    _category = 'geography';
    _questions = [];
    _isEditing = false;
    _currentStepIndex = 0;
    _error = null;
    
    // Resetar configurações para valores padrão
    _slideTime = 30;
    _totalTime = 300;
    _allowSkip = true;
    _showExplanation = true;
    _randomizeQuestions = false;
    _difficulty = 'medium';
    
    notifyListeners();
  }

  // Navegação entre steps
  void nextStep() {
    if (_currentStepIndex < _steps.length - 1 && canProceedToNextStep) {
      _currentStepIndex++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      notifyListeners();
    }
  }

  void goToStep(int index) {
    if (index >= 0 && index < _steps.length) {
      _currentStepIndex = index;
      notifyListeners();
    }
  }

  // Atualizar dados básicos
  void updateBasicConfig({
    required String title,
    required String description,
    required String category,
  }) {
    _title = title;
    _description = description;
    _category = category;
    notifyListeners();
  }

  // Atualizar configurações do challenge
  void updateChallengeConfig({
    required int slideTime,
    required int totalTime,
    required bool allowSkip,
    required bool showExplanation,
    required bool randomizeQuestions,
    required String difficulty,
  }) {
    _slideTime = slideTime;
    _totalTime = totalTime;
    _allowSkip = allowSkip;
    _showExplanation = showExplanation;
    _randomizeQuestions = randomizeQuestions;
    _difficulty = difficulty;
    notifyListeners();
  }

  // Gerenciar perguntas
  void addQuestion() {
    _questions.add(StudioQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      configs: StudioSlideConfig(
        slideTime: 30,
        allowSkip: true,
        showExplanation: true,
        difficulty: 'medium',
      ),
      data: StudioQuestionData(
        question: 'Nova pergunta',
        options: ['Opção A', 'Opção B', '', ''],
        correctAnswer: 0,
        explanation: 'Explicação da resposta correta',
        category: parseCategoria(_category),
      ),
    ));
    notifyListeners();
  }

  void addQuestionWithData(StudioQuestion question) {
    _questions.add(question);
    notifyListeners();
  }

  void removeQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _questions.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuestion(int index, StudioQuestion question) {
    if (index >= 0 && index < _questions.length) {
      _questions[index] = question;
      notifyListeners();
    }
  }

  void updateQuestionConfig(int index, {
    int? slideTime,
    bool? allowSkip,
    bool? showExplanation,
    String? difficulty,
  }) {
    if (index >= 0 && index < _questions.length) {
      final question = _questions[index];
      _questions[index] = StudioQuestion(
        id: question.id,
        createdAt: question.createdAt,
        updatedAt: DateTime.now(),
        configs: StudioSlideConfig(
          slideTime: slideTime ?? question.configs.slideTime,
          allowSkip: allowSkip ?? question.configs.allowSkip,
          showExplanation: showExplanation ?? question.configs.showExplanation,
          difficulty: difficulty ?? question.configs.difficulty,
          backgroundImage: question.configs.backgroundImage,
          backgroundColor: question.configs.backgroundColor,
        ),
        data: question.data,
      );
      notifyListeners();
    }
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _questions.removeAt(oldIndex);
    _questions.insert(newIndex, item);
    notifyListeners();
  }

  // Salvar challenge
  Future<bool> saveChallenge([BuildContext? context]) async {
    if (!canSaveChallenge) {
      _error = 'Dados incompletos para salvar o challenge';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      final challengeData = _buildChallengeData();
      final success = await _saveToApi(challengeData, context);
      
      if (success) {
        // Limpar dados após salvar
        startNewChallenge();
      }
      
      return success;
    } catch (e) {
      _error = 'Erro ao salvar challenge: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Map<String, dynamic> _buildChallengeData() {
    final data = {
      'title': _title,
      'description': _description,
      'category': _category,
      'questions': _questions.map((q) => q.toJson()).toList(),
      'slideTime': _slideTime,
      'totalTime': _totalTime,
      'allowSkip': _allowSkip,
      'showExplanation': _showExplanation,
      'randomizeQuestions': _randomizeQuestions,
      'difficulty': _difficulty,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Se estiver editando, incluir o ID
    if (_isEditing && _currentChallenge != null) {
      data['id'] = _currentChallenge!.id;
    } else {
      data['createdAt'] = DateTime.now().toIso8601String();
    }

    return data;
  }

  Future<bool> _saveToApi(Map<String, dynamic> data, [BuildContext? context]) async {
    try {
      final studioApiService = StudioApiService();
      final studioQuiz = StudioQuiz.fromJson(data);
      
      print('🚀 Enviando dados para API via StudioApiService');
      print('📦 Dados enviados: ${jsonEncode(data)}');
      
      final success = await studioApiService.saveQuiz(studioQuiz, context);
      
      if (success) {
        print('✅ Challenge salvo com sucesso via StudioApiService');
        return true;
      } else {
        print('❌ Erro ao salvar challenge via StudioApiService');
        _error = 'Erro ao salvar challenge';
        return false;
      }
    } catch (e) {
      print('❌ Erro ao salvar challenge: $e');
      _error = 'Erro ao salvar challenge: $e';
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Gerar perguntas de exemplo (temporário)
  List<StudioQuestion> _generateSampleQuestions() {
    return [
      StudioQuestion(
        id: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        configs: StudioSlideConfig(
          slideTime: 30,
          allowSkip: true,
          showExplanation: true,
          difficulty: 'medium',
        ),
        data: StudioQuestionData(
          question: 'Qual é a capital do Brasil?',
          options: ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador'],
          correctAnswer: 2,
          explanation: 'Brasília é a capital federal do Brasil desde 1960.',
          category: parseCategoria('geography'),
        ),
      ),
      StudioQuestion(
        id: '2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        configs: StudioSlideConfig(
          slideTime: 45,
          allowSkip: false,
          showExplanation: true,
          difficulty: 'hard',
        ),
        data: StudioQuestionData(
          question: 'Quem descobriu o Brasil?',
          options: ['Cristóvão Colombo', 'Pedro Álvares Cabral', 'Vasco da Gama', 'Fernão de Magalhães'],
          correctAnswer: 1,
          explanation: 'Pedro Álvares Cabral chegou ao Brasil em 22 de abril de 1500.',
          category: parseCategoria('history'),
        ),
      ),
    ];
  }
}

// Modelos para o Studio
class StudioStep {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  StudioStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
