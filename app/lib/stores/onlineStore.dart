import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/onlineModels.dart';
import '../services/onlineApiService.dart';
import 'sessionStore.dart';

class OnlineStore extends ChangeNotifier {
  final OnlineApiService _apiService = OnlineApiService();

  // Estado das salas
  List<GameRoom> _myRooms = [];
  List<GameRoom> _participatingRooms = [];
  GameRoom? _currentRoom;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<GameRoom> get myRooms => _myRooms;
  List<GameRoom> get participatingRooms => _participatingRooms;
  GameRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Salas ativas (não finalizadas)
  List<GameRoom> get activeMyRooms => 
      _myRooms.where((room) => !room.isFinished && !room.isExpired).toList();
  
  List<GameRoom> get activeParticipatingRooms => 
      _participatingRooms.where((room) => !room.isFinished && !room.isExpired).toList();

  // Salas finalizadas
  List<GameRoom> get finishedMyRooms => 
      _myRooms.where((room) => room.isFinished).toList();
  
  List<GameRoom> get finishedParticipatingRooms => 
      _participatingRooms.where((room) => room.isFinished).toList();

  // Limpar erro
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Definir erro
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Definir loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Carregar salas do usuário
  Future<void> loadMyRooms() async {
    try {
      _setLoading(true);
      _clearError();
      
      // TODO: Implementar endpoint para buscar salas do usuário
      // Por enquanto, vamos simular com dados vazios
      _myRooms = [];
      
    } catch (e) {
      _setError('Erro ao carregar suas salas: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Carregar salas como participante
  Future<void> loadParticipatingRooms() async {
    try {
      _setLoading(true);
      _clearError();
      
      // TODO: Implementar endpoint para buscar salas como participante
      // Por enquanto, vamos simular com dados vazios
      _participatingRooms = [];
      
    } catch (e) {
      _setError('Erro ao carregar salas como participante: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Criar nova sala
  Future<GameRoom?> createRoom(CreateRoomRequest request, BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();
      
      final sessionStore = context.read<SessionStore>();
      final token = sessionStore.accessToken;
      
      final room = await _apiService.createRoom(request, token);
      if (room != null) {
        _currentRoom = room;
        // Adicionar à lista de minhas salas
        _myRooms.insert(0, room);
        notifyListeners();
      }
      
      return room;
    } catch (e) {
      _setError('Erro ao criar sala: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar sala por código
  Future<GameRoom?> getRoomByCode(String roomCode) async {
    try {
      _setLoading(true);
      _clearError();
      
      final room = await _apiService.getRoomByCode(roomCode);
      return room;
    } catch (e) {
      _setError('Erro ao buscar sala: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Entrar na sala
  Future<bool> joinRoom(String roomCode, BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();
      
      final sessionStore = context.read<SessionStore>();
      final token = sessionStore.accessToken;
      
      final success = await _apiService.joinRoom(roomCode, token);
      if (success) {
        // Recarregar salas como participante
        await loadParticipatingRooms();
      }
      
      return success;
    } catch (e) {
      _setError('Erro ao entrar na sala: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Marcar como pronto
  Future<bool> setReady(String roomCode, bool isReady, BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();
      
      final sessionStore = context.read<SessionStore>();
      final token = sessionStore.accessToken;
      
      final success = await _apiService.setReady(roomCode, isReady, token);
      if (success) {
        // Atualizar sala atual se for a mesma
        if (_currentRoom?.roomCode == roomCode) {
          await refreshCurrentRoom();
        }
      }
      
      return success;
    } catch (e) {
      _setError('Erro ao atualizar status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Iniciar jogo (apenas host)
  Future<bool> startGame(String roomCode, BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();
      
      final sessionStore = context.read<SessionStore>();
      final token = sessionStore.accessToken;
      
      final success = await _apiService.startGame(roomCode, token);
      if (success) {
        // Atualizar sala atual
        await refreshCurrentRoom();
      }
      
      return success;
    } catch (e) {
      _setError('Erro ao iniciar jogo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Enviar resposta
  Future<bool> sendAnswer(String roomCode, AnswerRequest answer, BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();
      
      final sessionStore = context.read<SessionStore>();
      final token = sessionStore.accessToken;
      
      final success = await _apiService.sendAnswer(roomCode, answer, token);
      if (success) {
        // Atualizar sala atual
        await refreshCurrentRoom();
      }
      
      return success;
    } catch (e) {
      _setError('Erro ao enviar resposta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obter resultados da sala
  Future<List<PlayerResult>?> getRoomResults(String roomCode) async {
    try {
      _setLoading(true);
      _clearError();
      
      final results = await _apiService.getRoomResults(roomCode);
      return results;
    } catch (e) {
      _setError('Erro ao obter resultados: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Sair da sala
  Future<bool> leaveRoom(String roomCode, BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();
      
      final sessionStore = context.read<SessionStore>();
      final token = sessionStore.accessToken;
      
      final success = await _apiService.leaveRoom(roomCode, token);
      if (success) {
        // Remover das listas
        _myRooms.removeWhere((room) => room.roomCode == roomCode);
        _participatingRooms.removeWhere((room) => room.roomCode == roomCode);
        
        // Limpar sala atual se for a mesma
        if (_currentRoom?.roomCode == roomCode) {
          _currentRoom = null;
        }
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Erro ao sair da sala: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar sala atual
  Future<void> refreshCurrentRoom() async {
    if (_currentRoom == null) return;
    
    try {
      final updatedRoom = await _apiService.getRoomByCode(_currentRoom!.roomCode);
      if (updatedRoom != null) {
        _currentRoom = updatedRoom;
        
        // Atualizar nas listas também
        _updateRoomInLists(updatedRoom);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao atualizar sala atual: $e');
    }
  }

  // Atualizar sala nas listas
  void _updateRoomInLists(GameRoom updatedRoom) {
    // Atualizar em minhas salas
    final myRoomIndex = _myRooms.indexWhere((room) => room.roomCode == updatedRoom.roomCode);
    if (myRoomIndex != -1) {
      _myRooms[myRoomIndex] = updatedRoom;
    }
    
    // Atualizar em salas como participante
    final participatingRoomIndex = _participatingRooms.indexWhere((room) => room.roomCode == updatedRoom.roomCode);
    if (participatingRoomIndex != -1) {
      _participatingRooms[participatingRoomIndex] = updatedRoom;
    }
  }

  // Definir sala atual
  void setCurrentRoom(GameRoom room) {
    _currentRoom = room;
    notifyListeners();
  }

  // Limpar sala atual
  void clearCurrentRoom() {
    _currentRoom = null;
    notifyListeners();
  }

  // Recarregar todas as salas
  Future<void> refreshAllRooms() async {
    await Future.wait([
      loadMyRooms(),
      loadParticipatingRooms(),
    ]);
  }

  // Verificar se usuário é host de uma sala
  bool isHostOfRoom(String roomCode, String userId) {
    final room = _myRooms.firstWhere(
      (room) => room.roomCode == roomCode,
      orElse: () => _currentRoom!,
    );
    return room.hostUserId == userId;
  }

  // Verificar se usuário está participando de uma sala
  bool isParticipatingInRoom(String roomCode, String userId) {
    final allRooms = [..._myRooms, ..._participatingRooms];
    if (_currentRoom != null) {
      allRooms.add(_currentRoom!);
    }
    
    final room = allRooms.firstWhere(
      (room) => room.roomCode == roomCode,
      orElse: () => throw Exception('Sala não encontrada'),
    );
    
    return room.participants.any((participant) => participant.userId == userId);
  }

  // Obter sala por código das listas locais
  GameRoom? getRoomFromLists(String roomCode) {
    // Buscar em minhas salas
    final myRoom = _myRooms.firstWhere(
      (room) => room.roomCode == roomCode,
      orElse: () => throw Exception('Sala não encontrada'),
    );
    if (myRoom.roomCode == roomCode) return myRoom;
    
    // Buscar em salas como participante
    final participatingRoom = _participatingRooms.firstWhere(
      (room) => room.roomCode == roomCode,
      orElse: () => throw Exception('Sala não encontrada'),
    );
    if (participatingRoom.roomCode == roomCode) return participatingRoom;
    
    return null;
  }

  // Limpar todos os dados
  void clear() {
    _myRooms.clear();
    _participatingRooms.clear();
    _currentRoom = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
