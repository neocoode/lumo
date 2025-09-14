class GameRoom {
  final String roomCode;
  final String hostUserId;
  final String hostName;
  final String hostPhoto;
  final String challengeId;
  final String challengeTitle;
  final String challengeDescription;
  final int questionsCount;
  final String status; // waiting, playing, finished
  final int maxParticipants;
  final List<Participant> participants;
  final GameSettings gameSettings;
  final int currentQuestion;
  final List<PlayerResult> results;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime expiresAt;

  GameRoom({
    required this.roomCode,
    required this.hostUserId,
    required this.hostName,
    required this.hostPhoto,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeDescription,
    required this.questionsCount,
    required this.status,
    required this.maxParticipants,
    required this.participants,
    required this.gameSettings,
    required this.currentQuestion,
    required this.results,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    required this.expiresAt,
  });

  factory GameRoom.fromJson(Map<String, dynamic> json) {
    return GameRoom(
      roomCode: json['roomCode'] ?? '',
      hostUserId: json['host']['id'] ?? '',
      hostName: json['host']['name'] ?? '',
      hostPhoto: json['host']['photo'] ?? '',
      challengeId: json['challenge']['id'] ?? '',
      challengeTitle: json['challenge']['title'] ?? '',
      challengeDescription: json['challenge']['description'] ?? '',
      questionsCount: json['challenge']['questionsCount'] ?? 0,
      status: json['status'] ?? 'waiting',
      maxParticipants: json['maxParticipants'] ?? 6,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => Participant.fromJson(p))
          .toList() ?? [],
      gameSettings: GameSettings.fromJson(json['gameSettings'] ?? {}),
      currentQuestion: json['currentQuestion'] ?? 0,
      results: (json['results'] as List<dynamic>?)
          ?.map((r) => PlayerResult.fromJson(r))
          .toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      startedAt: json['startedAt'] != null 
          ? DateTime.tryParse(json['startedAt']) 
          : null,
      finishedAt: json['finishedAt'] != null 
          ? DateTime.tryParse(json['finishedAt']) 
          : null,
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'host': {
        'id': hostUserId,
        'name': hostName,
        'photo': hostPhoto,
      },
      'challenge': {
        'id': challengeId,
        'title': challengeTitle,
        'description': challengeDescription,
        'questionsCount': questionsCount,
      },
      'status': status,
      'maxParticipants': maxParticipants,
      'participants': participants.map((p) => p.toJson()).toList(),
      'gameSettings': gameSettings.toJson(),
      'currentQuestion': currentQuestion,
      'results': results.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isWaiting => status == 'waiting';
  bool get isPlaying => status == 'playing';
  bool get isFinished => status == 'finished';
  bool get isExpired => expiresAt.isBefore(DateTime.now());
  
  int get participantsCount => participants.length;
  bool get canJoin => isWaiting && participantsCount < maxParticipants && !isExpired;
  
  String get statusText {
    switch (status) {
      case 'waiting':
        return 'Aguardando';
      case 'playing':
        return 'Em andamento';
      case 'finished':
        return 'Finalizado';
      default:
        return 'Desconhecido';
    }
  }

  String get timeLeft {
    if (isExpired) return 'Expirado';
    if (isFinished) return 'Finalizado';
    
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Menos de 1m';
    }
  }
}

class Participant {
  final String userId;
  final String name;
  final String? photo;
  final bool isReady;
  final DateTime joinedAt;
  final int currentScore;
  final List<Answer> answers;

  Participant({
    required this.userId,
    required this.name,
    this.photo,
    required this.isReady,
    required this.joinedAt,
    required this.currentScore,
    required this.answers,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'],
      isReady: json['isReady'] ?? false,
      joinedAt: DateTime.tryParse(json['joinedAt'] ?? '') ?? DateTime.now(),
      currentScore: json['currentScore'] ?? 0,
      answers: (json['answers'] as List<dynamic>?)
          ?.map((a) => Answer.fromJson(a))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'photo': photo,
      'isReady': isReady,
      'joinedAt': joinedAt.toIso8601String(),
      'currentScore': currentScore,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class Answer {
  final int questionIndex;
  final int selectedAnswer;
  final bool isCorrect;
  final int timeSpent;
  final DateTime answeredAt;

  Answer({
    required this.questionIndex,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeSpent,
    required this.answeredAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionIndex: json['questionIndex'] ?? 0,
      selectedAnswer: json['selectedAnswer'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
      answeredAt: DateTime.tryParse(json['answeredAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }
}

class GameSettings {
  final int timePerQuestion;
  final bool allowSkip;
  final bool showExplanation;
  final bool randomizeQuestions;

  GameSettings({
    required this.timePerQuestion,
    required this.allowSkip,
    required this.showExplanation,
    required this.randomizeQuestions,
  });

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      timePerQuestion: json['timePerQuestion'] ?? 30,
      allowSkip: json['allowSkip'] ?? true,
      showExplanation: json['showExplanation'] ?? true,
      randomizeQuestions: json['randomizeQuestions'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timePerQuestion': timePerQuestion,
      'allowSkip': allowSkip,
      'showExplanation': showExplanation,
      'randomizeQuestions': randomizeQuestions,
    };
  }
}

class PlayerResult {
  final String userId;
  final String name;
  final String? photo;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int totalTime;
  final int position;

  PlayerResult({
    required this.userId,
    required this.name,
    this.photo,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.totalTime,
    required this.position,
  });

  factory PlayerResult.fromJson(Map<String, dynamic> json) {
    return PlayerResult(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'],
      finalScore: json['finalScore'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      totalTime: json['totalTime'] ?? 0,
      position: json['position'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'photo': photo,
      'finalScore': finalScore,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'totalTime': totalTime,
      'position': position,
    };
  }
}

class CreateRoomRequest {
  final String challengeId;
  final int maxParticipants;
  final GameSettings gameSettings;

  CreateRoomRequest({
    required this.challengeId,
    required this.maxParticipants,
    required this.gameSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'maxParticipants': maxParticipants,
      'gameSettings': gameSettings.toJson(),
    };
  }
}

class JoinRoomRequest {
  final String roomCode;

  JoinRoomRequest({
    required this.roomCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
    };
  }
}

class AnswerRequest {
  final int questionIndex;
  final int selectedAnswer;
  final int timeSpent;

  AnswerRequest({
    required this.questionIndex,
    required this.selectedAnswer,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'selectedAnswer': selectedAnswer,
      'timeSpent': timeSpent,
    };
  }
}
