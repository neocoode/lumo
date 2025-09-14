import 'dart:async';
import '../models/apiModels.dart';
import 'challengesApiService.dart';
import 'fallbackService.dart';

class ChallengesService implements IChallengesApiService {
  final IChallengesApiService _apiService;
  final FallbackService _fallbackService;
  bool _isApiAvailable = true;
  Timer? _healthCheckTimer;
  String? _lastError;

  ChallengesService({
    IChallengesApiService? apiService,
    FallbackService? fallbackService,
  })  : _apiService = apiService ?? ChallengesApiService(),
        _fallbackService = fallbackService ?? FallbackService() {
    _startHealthCheck();
  }

  void _startHealthCheck() {
    // Verifica a saúde da API a cada 30 segundos
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkApiHealth(),
    );
  }

  Future<void> _checkApiHealth() async {
    try {
      await _apiService.getCategories();
      if (!_isApiAvailable) {
        print('✅ API está disponível novamente');
        _isApiAvailable = true;
        _lastError = null;
      }
    } catch (e) {
      if (_isApiAvailable) {
        print('⚠️ API indisponível: $e');
        _isApiAvailable = false;
        _lastError = e.toString();
      }
    }
  }

  IChallengesApiService get _currentService =>
      _isApiAvailable ? _apiService : _fallbackService;

  @override
  Future<ISlideCollectionDocument> getChallenges() async {
    if (!_isApiAvailable) {
      throw Exception(
          'API indisponível. Use getOfflineChallenges() para dados offline.');
    }

    try {
      return await _apiService.getChallenges();
    } catch (e) {
      print('Erro na API: $e');
      _isApiAvailable = false;
      _lastError = e.toString();
      throw Exception(
          'API indisponível. Use getOfflineChallenges() para dados offline.');
    }
  }

  // Get user's challenges
  Future<List<ISlideCollectionDocument>> getUserChallenges() async {
    try {
      return await _apiService.getUserChallenges();
    } catch (e) {
      print('Erro ao buscar challenges do usuário: $e');
      _lastError = e.toString();
      return [];
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await _currentService.getCategories();
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getCategories();
      }
      rethrow;
    }
  }

  @override
  Future<List<ISlideData>> getChallengesByCategory(String category) async {
    try {
      return await _currentService.getChallengesByCategory(category);
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getChallengesByCategory(category);
      }
      rethrow;
    }
  }

  @override
  Future<ISlideData?> getSlideByIndex(int index) async {
    try {
      return await _currentService.getSlideByIndex(index);
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getSlideByIndex(index);
      }
      rethrow;
    }
  }

  @override
  Future<ISlideConfigs> getConfigsEmpty() async {
    try {
      return await _currentService.getConfigsEmpty();
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getConfigsEmpty();
      }
      rethrow;
    }
  }

  @override
  Future<ISlideConfigs> getConfigsWithAnswers() async {
    try {
      return await _currentService.getConfigsWithAnswers();
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getConfigsWithAnswers();
      }
      rethrow;
    }
  }

  @override
  Future<bool> updateSlideAnswer(int index, int answer) async {
    try {
      return await _currentService.updateSlideAnswer(index, answer);
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.updateSlideAnswer(index, answer);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      return await _currentService.getStats();
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getStats();
      }
      rethrow;
    }
  }

  @override
  Future<ISlideCollectionDocument> getChallengeById(String id) async {
    try {
      return await _currentService.getChallengeById(id);
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getChallengeById(id);
      }
      rethrow;
    }
  }

  // Buscar preview de quiz do studio
  Future<ISlideCollectionDocument> getStudioQuizPreview(String id) async {
    try {
      return await _apiService.getStudioQuizPreview(id);
    } catch (e) {
      print('Erro ao buscar preview do quiz do studio: $e');
      rethrow;
    }
  }

  // Métodos utilitários
  bool get isApiAvailable => _isApiAvailable;
  String? get lastError => _lastError;

  Future<void> forceApiCheck() async {
    await _checkApiHealth();
  }

  // Métodos para dados offline
  Future<ISlideCollectionDocument> getOfflineChallenges() async {
    return await _fallbackService.getChallenges();
  }

  Future<List<String>> getOfflineCategories() async {
    return await _fallbackService.getCategories();
  }

  Future<List<ISlideData>> getOfflineChallengesByCategory(
      String category) async {
    return await _fallbackService.getChallengesByCategory(category);
  }

  Future<ISlideData?> getOfflineSlideByIndex(int index) async {
    return await _fallbackService.getSlideByIndex(index);
  }

  void dispose() {
    _healthCheckTimer?.cancel();
    if (_apiService is ChallengesApiService) {
      (_apiService as ChallengesApiService).dispose();
    }
  }
}
