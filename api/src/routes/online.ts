import express from "express";
import { GameRoomModel } from "../models/GameRoom";
import { ChallengesCollectionModel } from "../models/ChallengesCollection";
import { User } from "../models/User";
import { authenticateToken, AuthenticatedRequest } from "../middleware/auth";
import mongoose from "mongoose";

const router = express.Router();

// POST /api/online/rooms - Criar nova sala online
router.post("/rooms", authenticateToken, async (req: AuthenticatedRequest, res: any) => {
  console.log("🏠 POST /api/online/rooms - Criando nova sala online para usuário:", req.user?.id);
  try {
    const {
      challengeId,
      maxParticipants = 6,
      gameSettings = {}
    } = req.body;

    // Validar dados obrigatórios
    if (!challengeId) {
      return res.status(400).json({
        success: false,
        message: "challengeId é obrigatório",
      });
    }

    // Verificar se o challenge existe e pertence ao usuário
    const userId = new mongoose.Types.ObjectId(req.user?.id);
    const challenge = await ChallengesCollectionModel.findOne({ 
      _id: challengeId, 
      userId 
    });

    if (!challenge) {
      return res.status(404).json({
        success: false,
        message: "Challenge não encontrado ou não pertence ao usuário",
      });
    }

    // Verificar se o usuário já tem uma sala ativa
    const existingRoom = await GameRoomModel.findOne({
      hostUserId: userId,
      status: { $in: ['waiting', 'playing'] }
    });

    if (existingRoom) {
      return res.status(400).json({
        success: false,
        message: "Você já possui uma sala ativa",
        data: {
          existingRoomCode: existingRoom.roomCode
        }
      });
    }

    // Gerar código único para a sala
    const roomCode = await GameRoomModel.generateUniqueRoomCode();

    // Configurações padrão do jogo
    const defaultGameSettings = {
      timePerQuestion: 30,
      allowSkip: true,
      showExplanation: true,
      randomizeQuestions: false,
      ...gameSettings
    };

    // Criar nova sala
    const newRoom = new GameRoomModel({
      roomCode,
      hostUserId: userId,
      challengeId: new mongoose.Types.ObjectId(challengeId),
      maxParticipants,
      gameSettings: defaultGameSettings,
      participants: [],
      status: 'waiting',
      currentQuestion: 0,
      results: [],
    });

    const savedRoom = await newRoom.save();

    console.log(`✅ Sala criada com sucesso: ${roomCode} para challenge: ${challengeId}`);

    res.status(201).json({
      success: true,
      message: "Sala criada com sucesso",
      data: {
        roomCode: savedRoom.roomCode,
        challengeTitle: challenge.configs.title,
        maxParticipants: savedRoom.maxParticipants,
        gameSettings: savedRoom.gameSettings,
        createdAt: savedRoom.createdAt,
        expiresAt: savedRoom.expiresAt,
      },
    });
  } catch (error) {
    console.error("❌ Erro ao criar sala online:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao criar sala online",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/online/rooms/:roomCode - Buscar sala por código
router.get("/rooms/:roomCode", async (req: any, res: any) => {
  const { roomCode } = req.params;
  console.log(`🔍 GET /api/online/rooms/${roomCode} - Buscando sala por código`);
  
  try {
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() })
      .populate('hostUserId', 'name photo')
      .populate('challengeId', 'configs.title configs.description data');

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    // Verificar se a sala expirou
    if (room.expiresAt < new Date()) {
      return res.status(410).json({
        success: false,
        message: "Sala expirada",
      });
    }

    console.log(`✅ Sala encontrada: ${roomCode}`);

    res.json({
      success: true,
      data: {
        roomCode: room.roomCode,
        host: {
          id: room.hostUserId._id,
          name: room.hostUserId.name,
          photo: room.hostUserId.photo,
        },
        challenge: {
          id: room.challengeId._id,
          title: room.challengeId.configs.title,
          description: room.challengeId.configs.description,
          questionsCount: room.challengeId.data.length,
        },
        status: room.status,
        maxParticipants: room.maxParticipants,
        participants: room.participants.map(p => ({
          userId: p.userId,
          name: p.name,
          photo: p.photo,
          isReady: p.isReady,
          currentScore: p.currentScore,
        })),
        gameSettings: room.gameSettings,
        currentQuestion: room.currentQuestion,
        createdAt: room.createdAt,
        expiresAt: room.expiresAt,
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao buscar sala ${roomCode}:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar sala",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// POST /api/online/rooms/:roomCode/join - Entrar na sala
router.post("/rooms/:roomCode/join", authenticateToken, async (req: AuthenticatedRequest, res: any) => {
  const { roomCode } = req.params;
  console.log(`🚪 POST /api/online/rooms/${roomCode}/join - Usuário ${req.user?.id} tentando entrar na sala`);
  
  try {
    const userId = new mongoose.Types.ObjectId(req.user?.id);
    
    // Buscar sala
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() });

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    // Verificar se a sala expirou
    if (room.expiresAt < new Date()) {
      return res.status(410).json({
        success: false,
        message: "Sala expirada",
      });
    }

    // Verificar se pode aceitar participantes
    if (!room.canAcceptParticipants()) {
      return res.status(400).json({
        success: false,
        message: "Sala não está aceitando novos participantes",
      });
    }

    // Verificar se o usuário já está na sala
    const existingParticipant = room.participants.find(p => p.userId.equals(userId));
    if (existingParticipant) {
      return res.status(400).json({
        success: false,
        message: "Você já está nesta sala",
      });
    }

    // Buscar dados do usuário
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "Usuário não encontrado",
      });
    }

    // Adicionar participante
    const newParticipant = {
      userId,
      name: user.name,
      photo: user.photo,
      isReady: false,
      joinedAt: new Date(),
      currentScore: 0,
      answers: [],
    };

    room.participants.push(newParticipant);
    await room.save();

    console.log(`✅ Usuário ${req.user?.id} entrou na sala ${roomCode}`);

    res.json({
      success: true,
      message: "Entrou na sala com sucesso",
      data: {
        roomCode: room.roomCode,
        participants: room.participants.map(p => ({
          userId: p.userId,
          name: p.name,
          photo: p.photo,
          isReady: p.isReady,
          currentScore: p.currentScore,
        })),
        canStart: room.allParticipantsReady(),
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao entrar na sala ${roomCode}:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao entrar na sala",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// PUT /api/online/rooms/:roomCode/ready - Marcar como pronto
router.put("/rooms/:roomCode/ready", authenticateToken, async (req: AuthenticatedRequest, res: any) => {
  const { roomCode } = req.params;
  const { isReady } = req.body;
  console.log(`✅ PUT /api/online/rooms/${roomCode}/ready - Usuário ${req.user?.id} marcando como pronto: ${isReady}`);
  
  try {
    const userId = new mongoose.Types.ObjectId(req.user?.id);
    
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() });

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    // Verificar se o usuário está na sala
    const participant = room.participants.find(p => p.userId.equals(userId));
    if (!participant) {
      return res.status(400).json({
        success: false,
        message: "Você não está nesta sala",
      });
    }

    // Atualizar status de pronto
    participant.isReady = isReady;
    await room.save();

    console.log(`✅ Status de pronto atualizado para usuário ${req.user?.id}`);

    res.json({
      success: true,
      message: isReady ? "Marcado como pronto" : "Marcado como não pronto",
      data: {
        isReady: participant.isReady,
        canStart: room.allParticipantsReady(),
        readyCount: room.participants.filter(p => p.isReady).length,
        totalParticipants: room.participants.length,
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao atualizar status de pronto:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao atualizar status",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// POST /api/online/rooms/:roomCode/start - Iniciar jogo (apenas host)
router.post("/rooms/:roomCode/start", authenticateToken, async (req: AuthenticatedRequest, res: any) => {
  const { roomCode } = req.params;
  console.log(`🎮 POST /api/online/rooms/${roomCode}/start - Host ${req.user?.id} iniciando jogo`);
  
  try {
    const userId = new mongoose.Types.ObjectId(req.user?.id);
    
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() });

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    // Verificar se é o host
    if (!room.hostUserId.equals(userId)) {
      return res.status(403).json({
        success: false,
        message: "Apenas o host pode iniciar o jogo",
      });
    }

    // Verificar se todos estão prontos
    if (!room.allParticipantsReady()) {
      return res.status(400).json({
        success: false,
        message: "Nem todos os participantes estão prontos",
      });
    }

    // Verificar se há pelo menos 2 participantes
    if (room.participants.length < 2) {
      return res.status(400).json({
        success: false,
        message: "É necessário pelo menos 2 participantes para iniciar",
      });
    }

    // Iniciar jogo
    room.status = 'playing';
    room.startedAt = new Date();
    room.currentQuestion = 0;
    await room.save();

    console.log(`✅ Jogo iniciado na sala ${roomCode}`);

    res.json({
      success: true,
      message: "Jogo iniciado com sucesso",
      data: {
        status: room.status,
        startedAt: room.startedAt,
        currentQuestion: room.currentQuestion,
        participants: room.participants.map(p => ({
          userId: p.userId,
          name: p.name,
          photo: p.photo,
          currentScore: p.currentScore,
        })),
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao iniciar jogo:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao iniciar jogo",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// POST /api/online/rooms/:roomCode/answer - Enviar resposta
router.post("/rooms/:roomCode/answer", authenticateToken, async (req: AuthenticatedRequest, res: any) => {
  const { roomCode } = req.params;
  const { questionIndex, selectedAnswer, timeSpent } = req.body;
  console.log(`📝 POST /api/online/rooms/${roomCode}/answer - Usuário ${req.user?.id} enviando resposta`);
  
  try {
    const userId = new mongoose.Types.ObjectId(req.user?.id);
    
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() })
      .populate('challengeId', 'data');

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    // Verificar se o jogo está em andamento
    if (room.status !== 'playing') {
      return res.status(400).json({
        success: false,
        message: "Jogo não está em andamento",
      });
    }

    // Verificar se o usuário está na sala
    const participant = room.participants.find(p => p.userId.equals(userId));
    if (!participant) {
      return res.status(400).json({
        success: false,
        message: "Você não está nesta sala",
      });
    }

    // Verificar se já respondeu esta pergunta
    const existingAnswer = participant.answers.find(a => a.questionIndex === questionIndex);
    if (existingAnswer) {
      return res.status(400).json({
        success: false,
        message: "Você já respondeu esta pergunta",
      });
    }

    // Validar dados da resposta
    if (questionIndex < 0 || questionIndex >= room.challengeId.data.length) {
      return res.status(400).json({
        success: false,
        message: "Índice da pergunta inválido",
      });
    }

    if (selectedAnswer < 0 || selectedAnswer > 3) {
      return res.status(400).json({
        success: false,
        message: "Resposta inválida",
      });
    }

    // Verificar se a resposta está correta
    const question = room.challengeId.data[questionIndex];
    const isCorrect = question.question.correctAnswer === selectedAnswer;
    
    // Calcular pontuação (exemplo: 100 pontos por resposta correta)
    const points = isCorrect ? 100 : 0;
    participant.currentScore += points;

    // Adicionar resposta
    const answer = {
      questionIndex,
      selectedAnswer,
      isCorrect,
      timeSpent: timeSpent || 0,
      answeredAt: new Date(),
    };

    participant.answers.push(answer);
    await room.save();

    console.log(`✅ Resposta registrada para usuário ${req.user?.id}: ${isCorrect ? 'correta' : 'incorreta'}`);

    res.json({
      success: true,
      message: "Resposta registrada com sucesso",
      data: {
        isCorrect,
        points,
        currentScore: participant.currentScore,
        totalAnswers: participant.answers.length,
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao registrar resposta:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao registrar resposta",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/online/rooms/:roomCode/results - Obter resultados finais
router.get("/rooms/:roomCode/results", async (req: any, res: any) => {
  const { roomCode } = req.params;
  console.log(`🏆 GET /api/online/rooms/${roomCode}/results - Buscando resultados finais`);
  
  try {
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() })
      .populate('challengeId', 'configs.title data');

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    // Verificar se o jogo terminou
    if (room.status !== 'finished' && room.results.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Jogo ainda não terminou",
      });
    }

    console.log(`✅ Resultados encontrados para sala ${roomCode}`);

    res.json({
      success: true,
      data: {
        roomCode: room.roomCode,
        challengeTitle: room.challengeId.configs.title,
        totalQuestions: room.challengeId.data.length,
        results: room.results,
        finishedAt: room.finishedAt,
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao buscar resultados:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar resultados",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// DELETE /api/online/rooms/:roomCode/leave - Sair da sala
router.delete("/rooms/:roomCode/leave", authenticateToken, async (req: AuthenticatedRequest, res: any) => {
  const { roomCode } = req.params;
  console.log(`🚪 DELETE /api/online/rooms/${roomCode}/leave - Usuário ${req.user?.id} saindo da sala`);
  
  try {
    const userId = new mongoose.Types.ObjectId(req.user?.id);
    
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() });

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    // Verificar se o usuário está na sala
    const participantIndex = room.participants.findIndex(p => p.userId.equals(userId));
    if (participantIndex === -1) {
      return res.status(400).json({
        success: false,
        message: "Você não está nesta sala",
      });
    }

    // Se for o host e o jogo não começou, deletar a sala
    if (room.hostUserId.equals(userId) && room.status === 'waiting') {
      await GameRoomModel.findByIdAndDelete(room._id);
      console.log(`🗑️ Sala ${roomCode} deletada pelo host`);
      
      return res.json({
        success: true,
        message: "Sala deletada com sucesso",
      });
    }

    // Remover participante
    room.participants.splice(participantIndex, 1);
    
    // Se não há mais participantes, deletar a sala
    if (room.participants.length === 0) {
      await GameRoomModel.findByIdAndDelete(room._id);
      console.log(`🗑️ Sala ${roomCode} deletada por falta de participantes`);
    } else {
      await room.save();
      console.log(`✅ Usuário ${req.user?.id} saiu da sala ${roomCode}`);
    }

    res.json({
      success: true,
      message: "Saiu da sala com sucesso",
    });
  } catch (error) {
    console.error(`❌ Erro ao sair da sala:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao sair da sala",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/online/rooms/:roomCode/status - Status atual da sala
router.get("/rooms/:roomCode/status", async (req: any, res: any) => {
  const { roomCode } = req.params;
  console.log(`📊 GET /api/online/rooms/${roomCode}/status - Verificando status da sala`);
  
  try {
    const room = await GameRoomModel.findOne({ roomCode: roomCode.toUpperCase() });

    if (!room) {
      return res.status(404).json({
        success: false,
        message: "Sala não encontrada",
      });
    }

    res.json({
      success: true,
      data: {
        roomCode: room.roomCode,
        status: room.status,
        currentQuestion: room.currentQuestion,
        participants: room.participants.map(p => ({
          userId: p.userId,
          name: p.name,
          photo: p.photo,
          isReady: p.isReady,
          currentScore: p.currentScore,
          answersCount: p.answers.length,
        })),
        canStart: room.allParticipantsReady(),
        readyCount: room.participants.filter(p => p.isReady).length,
        totalParticipants: room.participants.length,
        maxParticipants: room.maxParticipants,
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao verificar status:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao verificar status",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

export default router;
