import 'dart:async';
import '../models/apiModels.dart';
import 'slidesApiService.dart';
import 'fallbackService.dart';

class SlidesService implements ISlidesApiService {
  final ISlidesApiService _apiService;
  final FallbackService _fallbackService;
  bool _isApiAvailable = true;
  Timer? _healthCheckTimer;
  String? _lastError;

  SlidesService({
    ISlidesApiService? apiService,
    FallbackService? fallbackService,
  })  : _apiService = apiService ?? SlidesApiService(),
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

  ISlidesApiService get _currentService =>
      _isApiAvailable ? _apiService : _fallbackService;

  @override
  Future<ISlideCollectionDocument> getSlides() async {
    if (!_isApiAvailable) {
      throw Exception(
          'API indisponível. Use getOfflineSlides() para dados offline.');
    }

    try {
      return await _apiService.getSlides();
    } catch (e) {
      print('Erro na API: $e');
      _isApiAvailable = false;
      _lastError = e.toString();
      throw Exception(
          'API indisponível. Use getOfflineSlides() para dados offline.');
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
  Future<List<ISlideData>> getSlidesByCategory(String category) async {
    try {
      return await _currentService.getSlidesByCategory(category);
    } catch (e) {
      if (_isApiAvailable) {
        print('Erro na API, tentando fallback: $e');
        _isApiAvailable = false;
        return await _fallbackService.getSlidesByCategory(category);
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

  // Métodos utilitários
  bool get isApiAvailable => _isApiAvailable;
  String? get lastError => _lastError;

  Future<void> forceApiCheck() async {
    await _checkApiHealth();
  }

  // Métodos para dados offline
  Future<ISlideCollectionDocument> getOfflineSlides() async {
    return await _fallbackService.getSlides();
  }

  Future<List<String>> getOfflineCategories() async {
    return await _fallbackService.getCategories();
  }

  Future<List<ISlideData>> getOfflineSlidesByCategory(String category) async {
    return await _fallbackService.getSlidesByCategory(category);
  }

  Future<ISlideData?> getOfflineSlideByIndex(int index) async {
    return await _fallbackService.getSlideByIndex(index);
  }

  void dispose() {
    _healthCheckTimer?.cancel();
    if (_apiService is SlidesApiService) {
      (_apiService as SlidesApiService).dispose();
    }
  }
}
