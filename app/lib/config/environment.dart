class Environment {
  static const String _baseUrl = 'http://192.168.3.109:3000';
  static const String _apiPath = '/api';

  // URLs da API
  static String get baseUrl => _baseUrl;
  static String get apiUrl => '$_baseUrl$_apiPath';

  // Endpoints específicos
  static String get challengesEndpoint => '$apiUrl/challenges';
  static String get categoriesEndpoint => '$apiUrl/challenges/categories';
  static String get categoryEndpoint => '$apiUrl/category';
  static String get slideEndpoint => '$apiUrl/slide';
  static String get configsEmptyEndpoint => '$apiUrl/configs/empty';
  static String get configsWithAnswersEndpoint =>
      '$apiUrl/configs/with-answers';
  static String get statsEndpoint => '$apiUrl/stats';

  // Configurações de timeout
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Configurações de retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Headers padrão
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Configurações de debug
  static const bool enableLogging = true;
  static const bool enableApiLogging = true;
}
