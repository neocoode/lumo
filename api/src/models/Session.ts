import mongoose, { Document, Schema } from 'mongoose';

export interface ISession extends Document {
  _id: string;
  email: string; // Usar email como chave primária
  accessToken: string;
  refreshToken: string;
  expiresAt: Date;
  isActive: boolean;
  deviceInfo?: string;
  createdAt: Date;
  updatedAt?: Date;
}

const SessionSchema = new Schema<ISession>({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  accessToken: {
    type: String,
    required: true,
    unique: true,
  },
  refreshToken: {
    type: String,
    required: true,
    unique: true,
  },
  expiresAt: {
    type: Date,
    required: true,
    default: () => new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 horas
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  deviceInfo: {
    type: String,
    default: null,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: null,
  },
});

// Índices
SessionSchema.index({ expiresAt: 1 });
SessionSchema.index({ isActive: 1 });

// Middleware para atualizar updatedAt
SessionSchema.pre('save', function(next) {
  if (this.isModified() && !this.isNew) {
    this.updatedAt = new Date();
  }
  next();
});

// Middleware para limpar sessões expiradas
SessionSchema.pre('find', function() {
  this.where({ expiresAt: { $gt: new Date() } });
});

export const Session = mongoose.model<ISession>('Session', SessionSchema);
