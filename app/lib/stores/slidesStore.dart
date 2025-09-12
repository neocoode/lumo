import 'package:flutter/material.dart';
import '../models/apiModels.dart';
import '../services/slidesService.dart';

class SlidesStore extends ChangeNotifier {
  // Game state
  ISlideCollectionDocument? _slidesData;
  ISlideConfigs _configs = ISlideConfigs(
    slides: [],
    totalCorrect: 0,
    totalWrong: 0,
    totalQuestions: 0,
    totalAnswered: 0,
    accuracyPercentage: 0.0,
  );
  int _currentQuestion = 0;
  bool _gameStarted = false;
  bool _gameFinished = false;
  bool _loading = false;
  String? _error;
  bool _usingFallback = false;
  bool _isOfflineMode = false;

  // API service
  final SlidesService _slidesService = SlidesService();

  // Getters
  ISlideCollectionDocument? get slidesData => _slidesData;
  ISlideConfigs get configs => _configs;
  int get currentQuestion => _currentQuestion;
  bool get gameStarted => _gameStarted;
  bool get gameFinished => _gameFinished;
  bool get loading => _loading;
  String? get error => _error;
  bool get usingFallback => _usingFallback;
  bool get isOfflineMode => _isOfflineMode;

  // Calculated getters
  List<ISlideData> get slides => _slidesData?.data ?? [];
  int get totalQuestions => slides.length;
  int get score => _configs.totalCorrect;
  double get accuracyPercentage => _configs.accuracyPercentage;
  bool get hasNextQuestion => _currentQuestion < totalQuestions - 1;
  ISlideData? get currentSlide =>
      _currentQuestion < totalQuestions ? slides[_currentQuestion] : null;
  ISlideQuestion? get currentQuestionObj => currentSlide?.question;
  String? get currentBackgroundImage => currentSlide?.backgroundImage;
  Color? get currentBackgroundColor => currentSlide?.backgroundColorColor;
  List<String> get categories => _slidesData?.categories ?? [];

  // Initialize game - Load all data from API and keep in memory
  Future<void> startGame() async {
    _loading = true;
    _error = null;
    _isOfflineMode = false;
    notifyListeners();

    try {
      // Fetch all data from API once and keep in memory
      _slidesData = await _slidesService.getSlides();
      _configs = _slidesData!.configs;
      _currentQuestion = 0;
      _gameStarted = true;
      _gameFinished = false;
      _usingFallback = false;

      print('✅ All game data loaded from API and stored in memory');
      print(
          '📊 Loaded: ${_slidesData!.data.length} slides, ${_slidesData!.categories.length} categories');
    } catch (e) {
      _error = _slidesService.lastError ?? 'Erro ao carregar dados: $e';
      _isOfflineMode = true;
      print('❌ Error starting game: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Start game in offline mode
  Future<void> startOfflineGame() async {
    _loading = true;
    _error = null;
    _isOfflineMode = true;
    notifyListeners();

    try {
      // Fetch data from offline service
      _slidesData = await _slidesService.getOfflineSlides();
      _configs = _slidesData!.configs;
      _currentQuestion = 0;
      _gameStarted = true;
      _gameFinished = false;
      _usingFallback = true;

      print('📱 Data loaded from offline storage');
    } catch (e) {
      _error = 'Erro ao carregar dados offline: $e';
      print('❌ Error starting offline game: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Load game with specific configurations
  void loadGameWithConfigs(ISlideConfigs configs) {
    if (_slidesData == null) return;

    _configs = configs;
    _currentQuestion = 0;
    _gameStarted = true;
    _gameFinished = false;
    _error = null;

    notifyListeners();
  }

  // Answer question
  Future<void> answerQuestion(int answerIndex) async {
    if (_gameFinished ||
        _currentQuestion >= totalQuestions ||
        _currentQuestion < 0) {
      return;
    }

    final question = slides[_currentQuestion].question;
    final isCorrect = answerIndex == question.correctAnswer;

    // Update slide configurations
    if (_currentQuestion < _configs.slides.length) {
      _configs.slides[_currentQuestion] = ISlideConfig(
        activeIndex: _configs.slides[_currentQuestion].activeIndex,
        selectedAnswer: answerIndex,
      );
    }

    // Update statistics
    final totalAnswered = _configs.totalAnswered + 1;
    final totalCorrect = _configs.totalCorrect + (isCorrect ? 1 : 0);
    final totalWrong = _configs.totalWrong + (isCorrect ? 0 : 1);
    final accuracyPercentage =
        totalAnswered > 0 ? (totalCorrect / totalAnswered) * 100 : 0.0;

    _configs = ISlideConfigs(
      slides: _configs.slides,
      totalCorrect: totalCorrect,
      totalWrong: totalWrong,
      totalQuestions: _configs.totalQuestions,
      totalAnswered: totalAnswered,
      accuracyPercentage: accuracyPercentage,
    );

    // Note: All data is already in memory, no need to call API
    // The answer is automatically saved in the local state

    notifyListeners();
  }

  // Next question
  void nextQuestion() {
    if (_currentQuestion < totalQuestions - 1) {
      _currentQuestion++;
      notifyListeners();
    } else {
      finishGame();
    }
  }

  // Finish game
  Future<void> finishGame() async {
    _gameFinished = true;

    // All progress is already saved in memory
    print('✅ Game finished - All progress saved in local state');
    print(
        '📊 Final Score: ${_configs.totalCorrect}/${_configs.totalQuestions} (${_configs.accuracyPercentage.toStringAsFixed(1)}%)');

    notifyListeners();
  }

  // Restart game - Use data already in memory
  Future<void> restartGame() async {
    _currentQuestion = 0;
    _gameStarted = false;
    _gameFinished = false;
    _error = null;

    // Reset configurations using data already in memory
    if (_slidesData != null) {
      _configs = _slidesData!.configs;
      print('🔄 Game restarted using data from memory');
    } else {
      print('⚠️ No data in memory, need to reload');
    }

    notifyListeners();
  }

  // Return to home
  void returnHome() {
    restartGame();
  }

  // Get result message
  String getResultMessage() {
    final percentage = accuracyPercentage;

    if (percentage >= 90) {
      return "Excellent! You are a genius!";
    } else if (percentage >= 70) {
      return "Very good! You have good knowledge!";
    } else if (percentage >= 50) {
      return "Good work! Keep studying!";
    } else {
      return "Don't give up! Practice more!";
    }
  }

  // Get result color
  Color getResultColor() {
    final percentage = accuracyPercentage;

    if (percentage >= 70) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Get result icon
  IconData getResultIcon() {
    final percentage = accuracyPercentage;

    if (percentage >= 90) {
      return Icons.emoji_events;
    } else if (percentage >= 70) {
      return Icons.star;
    } else if (percentage >= 50) {
      return Icons.thumb_up;
    } else {
      return Icons.school;
    }
  }

  // Check if should show confetti
  bool get shouldShowConfetti => accuracyPercentage >= 70;

  // Load game with example configurations (for testing) - Use data from memory
  Future<void> loadExampleGame() async {
    try {
      _loading = true;
      notifyListeners();

      // Use data already in memory if available
      if (_slidesData != null) {
        _configs = await _slidesService.getConfigsWithAnswers();
        _currentQuestion = 0;
        _gameStarted = true;
        _gameFinished = false;
        _error = null;
        _usingFallback = !_slidesService.isApiAvailable;
        print('📝 Example game loaded using data from memory');
      } else {
        // Load data if not in memory
        _slidesData = await _slidesService.getSlides();
        _configs = await _slidesService.getConfigsWithAnswers();
        _currentQuestion = 0;
        _gameStarted = true;
        _gameFinished = false;
        _error = null;
        _usingFallback = !_slidesService.isApiAvailable;
        print('📝 Example game loaded with fresh data');
      }
    } catch (e) {
      _error = 'Error loading example: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Search slides by category - Use data from memory
  Future<List<ISlideData>> searchSlidesByCategory(String category) async {
    try {
      // Use data already in memory if available
      if (_slidesData != null) {
        final filteredSlides = _slidesData!.data.where((slide) {
          return slide.question.category.name.toLowerCase() ==
              category.toLowerCase();
        }).toList();
        print(
            '🔍 Found ${filteredSlides.length} slides for category: $category (from memory)');
        return filteredSlides;
      } else {
        // Fallback to API if no data in memory
        return await _slidesService.getSlidesByCategory(category);
      }
    } catch (e) {
      print('Error searching slides by category: $e');
      return [];
    }
  }

  // Get statistics - Use data from memory
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Use data already in memory if available
      if (_slidesData != null) {
        final stats = {
          'totalSlides': _slidesData!.data.length,
          'totalCategories': _slidesData!.categories.length,
          'slidesByCategory': {
            for (String category in _slidesData!.categories)
              category: _slidesData!.data.where((slide) {
                return slide.question.category.name.toLowerCase() ==
                    category.toLowerCase();
              }).length,
          },
          'currentGameStats': {
            'totalCorrect': _configs.totalCorrect,
            'totalWrong': _configs.totalWrong,
            'totalAnswered': _configs.totalAnswered,
            'accuracyPercentage': _configs.accuracyPercentage,
          }
        };
        print('📊 Statistics generated from memory data');
        return stats;
      } else {
        // Fallback to API if no data in memory
        return await _slidesService.getStats();
      }
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  // Check API status
  Future<void> checkApiStatus() async {
    await _slidesService.forceApiCheck();
    _usingFallback = !_slidesService.isApiAvailable;
    notifyListeners();
  }

  // Retry API connection
  Future<void> retryApiConnection() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _slidesService.forceApiCheck();
      if (_slidesService.isApiAvailable) {
        _isOfflineMode = false;
        await startGame();
      } else {
        _error = 'API ainda indisponível';
        _isOfflineMode = true;
      }
    } catch (e) {
      _error = 'Erro ao conectar com a API: $e';
      _isOfflineMode = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _slidesService.dispose();
    super.dispose();
  }
}
