import mongoose, { Document, Schema, Types } from "mongoose";

// Interface para resposta individual
export interface IAnswer {
  questionIndex: number;
  selectedAnswer: number;
  isCorrect: boolean;
  timeSpent: number;
  answeredAt: Date;
}

// Interface para participante da sala
export interface IParticipant {
  userId: Types.ObjectId;
  name: string;
  photo?: string;
  isReady: boolean;
  joinedAt: Date;
  currentScore: number;
  answers: IAnswer[];
}

// Interface para resultado final do jogador
export interface IPlayerResult {
  userId: Types.ObjectId;
  name: string;
  photo?: string;
  finalScore: number;
  correctAnswers: number;
  totalQuestions: number;
  accuracy: number;
  totalTime: number;
  position: number;
}

// Interface para configurações do jogo
export interface IGameSettings {
  timePerQuestion: number;
  allowSkip: boolean;
  showExplanation: boolean;
  randomizeQuestions: boolean;
}

// Interface principal do documento GameRoom
export interface IGameRoomDocument extends Document {
  roomCode: string;
  hostUserId: Types.ObjectId;
  challengeId: Types.ObjectId;
  status: 'waiting' | 'playing' | 'finished';
  maxParticipants: number;
  participants: IParticipant[];
  gameSettings: IGameSettings;
  currentQuestion: number;
  results: IPlayerResult[];
  createdAt: Date;
  startedAt?: Date;
  finishedAt?: Date;
  expiresAt: Date;
}

// Schema para resposta individual
const AnswerSchema = new Schema<IAnswer>(
  {
    questionIndex: {
      type: Number,
      required: true,
      min: 0,
    },
    selectedAnswer: {
      type: Number,
      required: true,
      min: 0,
      max: 3,
    },
    isCorrect: {
      type: Boolean,
      required: true,
    },
    timeSpent: {
      type: Number,
      required: true,
      min: 0,
    },
    answeredAt: {
      type: Date,
      required: true,
      default: Date.now,
    },
  },
  { _id: false }
);

// Schema para participante
const ParticipantSchema = new Schema<IParticipant>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    photo: {
      type: String,
      default: null,
    },
    isReady: {
      type: Boolean,
      default: false,
    },
    joinedAt: {
      type: Date,
      required: true,
      default: Date.now,
    },
    currentScore: {
      type: Number,
      default: 0,
      min: 0,
    },
    answers: {
      type: [AnswerSchema],
      default: [],
    },
  },
  { _id: false }
);

// Schema para resultado final
const PlayerResultSchema = new Schema<IPlayerResult>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    photo: {
      type: String,
      default: null,
    },
    finalScore: {
      type: Number,
      required: true,
      min: 0,
    },
    correctAnswers: {
      type: Number,
      required: true,
      min: 0,
    },
    totalQuestions: {
      type: Number,
      required: true,
      min: 0,
    },
    accuracy: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    totalTime: {
      type: Number,
      required: true,
      min: 0,
    },
    position: {
      type: Number,
      required: true,
      min: 1,
    },
  },
  { _id: false }
);

// Schema para configurações do jogo
const GameSettingsSchema = new Schema<IGameSettings>(
  {
    timePerQuestion: {
      type: Number,
      default: 30,
      min: 5,
      max: 300,
    },
    allowSkip: {
      type: Boolean,
      default: true,
    },
    showExplanation: {
      type: Boolean,
      default: true,
    },
    randomizeQuestions: {
      type: Boolean,
      default: false,
    },
  },
  { _id: false }
);

// Schema principal da GameRoom
const GameRoomSchema = new Schema<IGameRoomDocument>(
  {
    roomCode: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      length: 6,
    },
    hostUserId: {
      type: Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    challengeId: {
      type: Schema.Types.ObjectId,
      required: true,
      ref: "ChallengesCollection",
    },
    status: {
      type: String,
      enum: ['waiting', 'playing', 'finished'],
      default: 'waiting',
    },
    maxParticipants: {
      type: Number,
      default: 6,
      min: 2,
      max: 12,
    },
    participants: {
      type: [ParticipantSchema],
      default: [],
    },
    gameSettings: {
      type: GameSettingsSchema,
      required: true,
    },
    currentQuestion: {
      type: Number,
      default: 0,
      min: 0,
    },
    results: {
      type: [PlayerResultSchema],
      default: [],
    },
    startedAt: {
      type: Date,
      default: null,
    },
    finishedAt: {
      type: Date,
      default: null,
    },
    expiresAt: {
      type: Date,
      required: true,
      default: () => new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 horas
    },
  },
  {
    timestamps: true,
  }
);

// Índices para performance
GameRoomSchema.index({ roomCode: 1 });
GameRoomSchema.index({ hostUserId: 1 });
GameRoomSchema.index({ status: 1 });
GameRoomSchema.index({ expiresAt: 1 });

// Middleware para limpeza automática de salas expiradas
GameRoomSchema.pre('save', function (next) {
  if (this.isNew) {
    // Define expiração para 24 horas a partir da criação
    this.expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
  }
  next();
});

// Método estático para gerar código único
GameRoomSchema.statics.generateUniqueRoomCode = async function (): Promise<string> {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let roomCode: string;
  
  do {
    roomCode = '';
    for (let i = 0; i < 6; i++) {
      roomCode += characters.charAt(Math.floor(Math.random() * characters.length));
    }
  } while (await this.findOne({ roomCode }));
  
  return roomCode;
};

// Método para verificar se a sala pode aceitar mais participantes
GameRoomSchema.methods.canAcceptParticipants = function (): boolean {
  return this.status === 'waiting' && this.participants.length < this.maxParticipants;
};

// Método para verificar se todos os participantes estão prontos
GameRoomSchema.methods.allParticipantsReady = function (): boolean {
  return this.participants.length >= 2 && this.participants.every((p: IParticipant) => p.isReady);
};

export const GameRoomModel = mongoose.model<IGameRoomDocument>(
  "GameRoom",
  GameRoomSchema,
  "gameRooms"
);
