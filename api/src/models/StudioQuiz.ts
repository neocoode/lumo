import mongoose, { Document, Schema } from 'mongoose';

// Interface para uma pergunta do quiz
export interface IStudioQuestion {
  id: string;
  question: string;
  options: string[];
  correctAnswer: number;
  explanation: string;
  category: string;
  imagePath?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Interface para configurações do quiz
export interface IStudioQuizConfig {
  title: string;
  description: string;
  backgroundColor: string;
  backgroundImage: string;
  timePerQuestion: number;
  showExplanation: boolean;
  shuffleQuestions: boolean;
  shuffleOptions: boolean;
}

// Interface principal do quiz
export interface IStudioQuiz extends Document {
  _id: string;
  title: string;
  description: string;
  questions: IStudioQuestion[];
  config: IStudioQuizConfig;
  authorId: string;
  createdAt: Date;
  updatedAt: Date;
}

// Schema para pergunta
const StudioQuestionSchema = new Schema<IStudioQuestion>({
  id: { type: String, required: true },
  question: { type: String, required: true, trim: true },
  options: [{ type: String, required: true, trim: true }],
  correctAnswer: { type: Number, required: true, min: 0 },
  explanation: { type: String, required: true, trim: true },
  category: { 
    type: String, 
    required: true,
    enum: ['geography', 'science', 'literature', 'history', 'mathematics', 'biology']
  },
  imagePath: { type: String },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Schema para configurações
const StudioQuizConfigSchema = new Schema<IStudioQuizConfig>({
  title: { type: String, required: true, trim: true },
  description: { type: String, required: true, trim: true },
  backgroundColor: { type: String, required: true, default: '#667eea' },
  backgroundImage: { type: String, required: true, default: 'assets/images/default.svg' },
  timePerQuestion: { type: Number, default: 0, min: 0 },
  showExplanation: { type: Boolean, default: true },
  shuffleQuestions: { type: Boolean, default: false },
  shuffleOptions: { type: Boolean, default: false }
});

// Schema principal do quiz
const StudioQuizSchema = new Schema<IStudioQuiz>({
  title: { 
    type: String, 
    required: true, 
    trim: true,
    minlength: 3,
    maxlength: 100
  },
  description: { 
    type: String, 
    required: true, 
    trim: true,
    minlength: 10,
    maxlength: 500
  },
  questions: [StudioQuestionSchema],
  config: { type: StudioQuizConfigSchema, required: true },
  authorId: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Middleware para atualizar updatedAt
StudioQuizSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Middleware para atualizar updatedAt das perguntas
StudioQuestionSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Índices para melhor performance
StudioQuizSchema.index({ authorId: 1, createdAt: -1 });
StudioQuizSchema.index({ title: 'text', description: 'text' });

export const StudioQuizModel = mongoose.model<IStudioQuiz>('StudioQuiz', StudioQuizSchema);
