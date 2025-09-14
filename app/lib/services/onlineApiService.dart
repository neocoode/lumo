import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/onlineModels.dart';

class OnlineApiService {
  final String _baseUrl = Environment.apiUrl;

  // Headers padrão
  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Criar nova sala
  Future<GameRoom?> createRoom(CreateRoomRequest request, String? token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/online/rooms'),
        headers: _getHeaders(token),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Para criar sala, precisamos buscar os detalhes completos
          final roomCode = data['data']['roomCode'];
          return await getRoomByCode(roomCode);
        }
      }
      
      throw Exception('Erro ao criar sala: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Buscar sala por código
  Future<GameRoom?> getRoomByCode(String roomCode, [String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return GameRoom.fromJson(data['data']);
        }
      } else if (response.statusCode == 404) {
        return null;
      }
      
      throw Exception('Erro ao buscar sala: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Entrar na sala
  Future<bool> joinRoom(String roomCode, String? token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode/join'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      
      throw Exception('Erro ao entrar na sala: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Marcar como pronto
  Future<bool> setReady(String roomCode, bool isReady, String? token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode/ready'),
        headers: _getHeaders(token),
        body: jsonEncode({'isReady': isReady}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      
      throw Exception('Erro ao atualizar status: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Iniciar jogo
  Future<bool> startGame(String roomCode, String? token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode/start'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      
      throw Exception('Erro ao iniciar jogo: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Enviar resposta
  Future<bool> sendAnswer(String roomCode, AnswerRequest answer, String? token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode/answer'),
        headers: _getHeaders(token),
        body: jsonEncode(answer.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      
      throw Exception('Erro ao enviar resposta: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Obter resultados da sala
  Future<List<PlayerResult>?> getRoomResults(String roomCode, [String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode/results'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final results = data['data']['results'] as List<dynamic>;
          return results.map((r) => PlayerResult.fromJson(r)).toList();
        }
      }
      
      throw Exception('Erro ao obter resultados: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Sair da sala
  Future<bool> leaveRoom(String roomCode, String? token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode/leave'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      
      throw Exception('Erro ao sair da sala: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Obter status da sala
  Future<GameRoom?> getRoomStatus(String roomCode, [String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/online/rooms/$roomCode/status'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // O endpoint de status retorna dados parciais, vamos usar getRoomByCode para dados completos
          return await getRoomByCode(roomCode);
        }
      }
      
      throw Exception('Erro ao obter status: ${response.body}');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // TODO: Implementar endpoints para buscar salas do usuário
  // Future<List<GameRoom>> getMyRooms() async { ... }
  // Future<List<GameRoom>> getParticipatingRooms() async { ... }
}
