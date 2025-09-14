import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/authModels.dart';
import '../services/authService.dart';
import '../services/encryptionService.dart';

class SessionStore extends ChangeNotifier {
  User? _user;
  Session? _session;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  // Getters
  User? get user => _user;
  Session? get session => _session;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get accessToken => _session?.accessToken;
  String? get refreshToken => _session?.refreshToken;

  SessionStore() {
    _loadStoredSession();
  }

  // Carregar sessão armazenada
  Future<void> _loadStoredSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final sessionJson = prefs.getString('session');
      final isLoggedInStored = prefs.getBool('isLoggedIn') ?? false;

      if (userJson != null && sessionJson != null && isLoggedInStored) {
        try {
          // Parse JSON strings
          final userData =
              Map<String, dynamic>.from(Uri.splitQueryString(userJson));
          final sessionData =
              Map<String, dynamic>.from(Uri.splitQueryString(sessionJson));

          _user = User.fromJson(userData);
          _session = Session.fromJson(sessionData);
          _isLoggedIn = true;

          print('✅ Sessão carregada com sucesso');

          // Verificar se o token ainda é válido
          if (_session!.isExpired) {
            print('Token expirado, tentando renovar...');
            await _refreshToken();
          }
        } catch (e) {
          print('Erro ao fazer parse dos dados salvos: $e');
          await _clearSession();
        }
      }
    } catch (e) {
      print('Erro ao carregar sessão: $e');
      await _clearSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Salvar sessão localmente
  Future<void> _saveSession(
      {bool rememberMe = false, String? email, String? password}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null && _session != null) {
        // Salvar dados do usuário
        final userJson = _user!.toJson();
        await prefs.setString('user', userJson.toString());

        // Salvar dados da sessão
        final sessionJson = _session!.toJson();
        await prefs.setString('session', sessionJson.toString());

        await prefs.setBool('isLoggedIn', _isLoggedIn);
        await prefs.setBool('rememberMe', rememberMe);

        // Salvar credenciais se lembrar-me estiver ativo
        if (rememberMe && email != null && password != null) {
          // Criptografar email e senha antes de salvar
          final encryptedEmail = EncryptionService.encryptSensitiveData(email);
          final encryptedPassword = EncryptionService.encryptPassword(password);
          
          await prefs.setString('savedEmail', encryptedEmail);
          await prefs.setString('savedPassword', encryptedPassword);
          await prefs.setString('originalEmail', email); // Salvar email original para exibição
        } else if (!rememberMe) {
          // Limpar credenciais se lembrar-me estiver desativado
          await prefs.remove('savedEmail');
          await prefs.remove('savedPassword');
          await prefs.remove('originalEmail');
        }

        print('✅ Sessão salva com sucesso');
      }
    } catch (e) {
      print('Erro ao salvar sessão: $e');
    }
  }

  // Limpar sessão
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('session');
      await prefs.remove('isLoggedIn');
      await prefs.remove('rememberMe');
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
      await prefs.remove('originalEmail');
    } catch (e) {
      print('Erro ao limpar sessão: $e');
    }
  }

  // Limpar dados da sessão (com opção de preservar credenciais)
  Future<void> _clearSessionData({bool keepCredentials = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('session');
      await prefs.remove('isLoggedIn');
      
      if (!keepCredentials) {
        // Se não deve manter credenciais, limpar tudo
        await prefs.remove('rememberMe');
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
        await prefs.remove('originalEmail');
      }
      // Se keepCredentials = true, mantém as credenciais para o próximo login
    } catch (e) {
      print('Erro ao limpar dados da sessão: $e');
    }
  }

  // Login
  Future<bool> login(String email, String password,
      {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Iniciando login para: $email');

      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      print('🔄 Chamando AuthService...');
      final response = await _authService.login(request);
      print('✅ Resposta recebida do AuthService');

      _user = response.user;
      _session = response.session;
      _isLoggedIn = true;

      print('🔄 Salvando sessão...');
      await _saveSession(
          rememberMe: rememberMe, email: email, password: password);

      print('✅ Login realizado com sucesso');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erro no login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registro
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        name: name,
      );

      final response = await _authService.register(request);

      _user = response.user;
      _session = response.session;
      _isLoggedIn = true;

      await _saveSession();

      print('✅ Registro realizado com sucesso');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erro no registro: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_session != null) {
        await _authService.logout(_session!.refreshToken);
      }
    } catch (e) {
      print('Erro no logout: $e');
    } finally {
      // Verificar se deve preservar credenciais do "Lembrar-me"
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      
      _user = null;
      _session = null;
      _isLoggedIn = false;
      _error = null;

      // Limpar apenas dados da sessão, preservar credenciais se "Lembrar-me" estiver ativo
      await _clearSessionData(keepCredentials: rememberMe);
      _isLoading = false;
      notifyListeners();

      print('✅ Logout realizado');
    }
  }

  // Refresh token
  Future<bool> _refreshToken() async {
    if (_session?.refreshToken == null) return false;

    try {
      final request = RefreshTokenRequest(
        refreshToken: _session!.refreshToken,
      );

      final response = await _authService.refreshToken(request);

      _session = response.session;
      await _saveSession();

      print('✅ Token renovado com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao renovar token: $e');
      await logout();
      return false;
    }
  }

  // Esqueceu a senha
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = ForgotPasswordRequest(email: email);
      await _authService.forgotPassword(request);

      print('✅ Email de recuperação enviado');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erro ao enviar email: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar se está autenticado
  bool isAuthenticated() {
    return _isLoggedIn;
  }

  // Atualizar perfil do usuário
  Future<bool> updateProfile({String? name, String? photo}) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        name: name ?? _user!.name,
        photo: photo ?? _user!.photo,
        updatedAt: DateTime.now(),
      );

      _user = updatedUser;
      await _saveSession();

      print('✅ Perfil atualizado');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erro ao atualizar perfil: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obter credenciais salvas
  Future<Map<String, dynamic>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      
      if (!rememberMe) {
        return {'email': null, 'password': null, 'rememberMe': false};
      }
      
      // Retornar email original (não criptografado) para exibição
      final originalEmail = prefs.getString('originalEmail');
      final encryptedPassword = prefs.getString('savedPassword');
      
      return {
        'email': originalEmail,
        'password': encryptedPassword, // Senha criptografada (não pode ser descriptografada)
        'rememberMe': rememberMe,
      };
    } catch (e) {
      print('Erro ao obter credenciais salvas: $e');
      return {'email': null, 'password': null, 'rememberMe': false};
    }
  }
  
  // Verificar se tem credenciais salvas
  Future<bool> hasSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      final originalEmail = prefs.getString('originalEmail');
      return rememberMe && originalEmail != null;
    } catch (e) {
      print('Erro ao verificar credenciais salvas: $e');
      return false;
    }
  }
}
