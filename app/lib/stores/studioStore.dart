import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/apiModels.dart';
import '../services/challengesListService.dart';

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
      case 2: // Configurações do desafio
        return _slideTime > 0 && _totalTime > 0;
      case 3: // Revisão
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
        id: 'challenge_config',
        title: 'Configurações do Desafio',
        description: 'Configure tempo e comportamento do challenge',
        icon: Icons.timer_rounded,
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
      question: 'Nova pergunta',
      options: ['Opção A', 'Opção B', '', ''],
      correctAnswer: 0,
      explanation: 'Explicação da resposta correta',
      category: _category,
    ));
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

  void reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _questions.removeAt(oldIndex);
    _questions.insert(newIndex, item);
    notifyListeners();
  }

  // Salvar challenge
  Future<bool> saveChallenge() async {
    if (!canSaveChallenge) {
      _error = 'Dados incompletos para salvar o challenge';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      final challengeData = _buildChallengeData();
      final success = await _saveToApi(challengeData);
      
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

  Future<bool> _saveToApi(Map<String, dynamic> data) async {
    try {
      final url = '${Environment.apiUrl}/studio/save';
      print('🚀 Enviando dados para: $url');
      print('📦 Dados enviados: ${jsonEncode(data)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('📡 Resposta recebida: ${response.statusCode}');
      print('📄 Corpo da resposta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('✅ Challenge salvo com sucesso: ${responseData['data']['id']}');
          return true;
        } else {
          _error = responseData['message'] ?? 'Erro ao salvar challenge';
          print('❌ Erro na resposta: $_error');
          return false;
        }
      } else {
        final responseData = jsonDecode(response.body);
        _error = responseData['message'] ?? 'Erro na API: ${response.statusCode}';
        print('❌ Erro HTTP: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      print('❌ Erro de conexão: $_error');
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
        question: 'Qual é a capital do Brasil?',
        options: ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador'],
        correctAnswer: 2,
        explanation: 'Brasília é a capital federal do Brasil desde 1960.',
        category: 'geography',
      ),
      StudioQuestion(
        question: 'Quem descobriu o Brasil?',
        options: ['Cristóvão Colombo', 'Pedro Álvares Cabral', 'Vasco da Gama', 'Fernão de Magalhães'],
        correctAnswer: 1,
        explanation: 'Pedro Álvares Cabral chegou ao Brasil em 22 de abril de 1500.',
        category: 'history',
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

class StudioQuestion {
  String question;
  List<String> options;
  int correctAnswer;
  String explanation;
  String category;
  String? imagePath;

  StudioQuestion({
    this.question = '',
    this.options = const ['', '', '', ''],
    this.correctAnswer = 0,
    this.explanation = '',
    this.category = 'geography',
    this.imagePath,
  });

  bool get isValid {
    return question.isNotEmpty &&
           options.where((option) => option.isNotEmpty).length >= 2 && // Pelo menos 2 opções preenchidas
           explanation.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'imagePath': imagePath,
    };
  }

  factory StudioQuestion.fromJson(Map<String, dynamic> json) {
    return StudioQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? ['', '', '', '']),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? 'geography',
      imagePath: json['imagePath'],
    );
  }
}