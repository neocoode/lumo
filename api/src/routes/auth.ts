import express, { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { User, IUser } from '../models/User';
import { Session, ISession } from '../models/Session';

const router = express.Router();

// Configurações JWT
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'your-refresh-secret';
const ACCESS_TOKEN_EXPIRES = '1h';
const REFRESH_TOKEN_EXPIRES = '7d';

// Função para gerar tokens
const generateTokens = (email: string) => {
  const accessToken = jwt.sign(
    { email, type: 'access' },
    JWT_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRES }
  );
  
  const refreshToken = jwt.sign(
    { email, type: 'refresh' },
    JWT_REFRESH_SECRET,
    { expiresIn: REFRESH_TOKEN_EXPIRES }
  );

  return { accessToken, refreshToken };
};

// Função para criar sessão
const createSession = async (email: string, deviceInfo?: string) => {
  // Remover sessão existente se houver
  await Session.findOneAndDelete({ email });
  
  const { accessToken, refreshToken } = generateTokens(email);
  
  const expiresAt = new Date();
  expiresAt.setHours(expiresAt.getHours() + 24); // 24 horas

  const session = new Session({
    email,
    accessToken,
    refreshToken,
    expiresAt,
    deviceInfo,
  });

  await session.save();
  return session;
};

// POST /auth/register
router.post('/register', async (req: Request, res: Response) => {
  try {
    const { email, password, name } = req.body;

    // Validações
    if (!email || !password || !name) {
      return res.status(400).json({
        success: false,
        message: 'Email, senha e nome são obrigatórios',
        statusCode: 400,
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'A senha deve ter pelo menos 6 caracteres',
        statusCode: 400,
      });
    }

    // Verificar se usuário já existe
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Usuário já existe com este email',
        statusCode: 409,
      });
    }

    // Hash da senha
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Criar usuário
    const user = new User({
      email: email.toLowerCase(),
      name,
      password: hashedPassword,
    });

    await user.save();

    // Criar sessão
    const session = await createSession(user.email, req.get('User-Agent'));

    // Resposta sem senha
    const userResponse = {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      photo: user.photo,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
    };

    const sessionResponse = {
      id: session._id.toString(),
      userId: session.userId,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      createdAt: session.createdAt,
      isActive: session.isActive,
      deviceInfo: session.deviceInfo,
    };

    res.status(201).json({
      success: true,
      message: 'Usuário criado com sucesso',
      data: {
        user: userResponse,
        session: sessionResponse,
      },
    });
  } catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500,
    });
  }
});

// POST /auth/login
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { email, password, rememberMe } = req.body;

    // Validações
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email e senha são obrigatórios',
        statusCode: 400,
      });
    }

    // Buscar usuário
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Credenciais inválidas',
        statusCode: 401,
      });
    }

    // Verificar senha
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Credenciais inválidas',
        statusCode: 401,
      });
    }

    // Verificar se usuário está ativo
    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        message: 'Conta desativada',
        statusCode: 403,
      });
    }

    // Criar nova sessão (substitui a anterior automaticamente)
    const session = await createSession(user.email, req.get('User-Agent'));

    // Resposta sem senha
    const userResponse = {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      photo: user.photo,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
    };

    const sessionResponse = {
      id: session._id.toString(),
      userId: session.userId,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      createdAt: session.createdAt,
      isActive: session.isActive,
      deviceInfo: session.deviceInfo,
    };

    res.json({
      success: true,
      message: 'Login realizado com sucesso',
      data: {
        user: userResponse,
        session: sessionResponse,
      },
    });
  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500,
    });
  }
});

// POST /auth/refresh
router.post('/refresh', async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token é obrigatório',
        statusCode: 400,
      });
    }

    // Verificar refresh token
    const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET) as any;
    
    // Buscar sessão
    const session = await Session.findOne({
      refreshToken,
      isActive: true,
      expiresAt: { $gt: new Date() },
    });

    if (!session) {
      return res.status(401).json({
        success: false,
        message: 'Refresh token inválido ou expirado',
        statusCode: 401,
      });
    }

    // Buscar usuário
    const user = await User.findOne({ email: session.email });
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Usuário não encontrado ou inativo',
        statusCode: 401,
      });
    }

    // Criar nova sessão (substitui a anterior automaticamente)
    const newSession = await createSession(user.email, req.get('User-Agent'));

    // Resposta
    const userResponse = {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      photo: user.photo,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
    };

    const sessionResponse = {
      id: newSession._id.toString(),
      userId: newSession.userId,
      accessToken: newSession.accessToken,
      refreshToken: newSession.refreshToken,
      expiresAt: newSession.expiresAt,
      createdAt: newSession.createdAt,
      isActive: newSession.isActive,
      deviceInfo: newSession.deviceInfo,
    };

    res.json({
      success: true,
      message: 'Token renovado com sucesso',
      data: {
        user: userResponse,
        session: sessionResponse,
      },
    });
  } catch (error) {
    console.error('Erro ao renovar token:', error);
    res.status(401).json({
      success: false,
      message: 'Refresh token inválido',
      statusCode: 401,
    });
  }
});

// POST /auth/logout
router.post('/logout', async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token é obrigatório',
        statusCode: 400,
      });
    }

    // Desativar sessão
    await Session.updateOne(
      { refreshToken },
      { isActive: false }
    );

    res.json({
      success: true,
      message: 'Logout realizado com sucesso',
    });
  } catch (error) {
    console.error('Erro no logout:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500,
    });
  }
});

// POST /auth/forgot-password
router.post('/forgot-password', async (req: Request, res: Response) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email é obrigatório',
        statusCode: 400,
      });
    }

    // Buscar usuário
    const user = await User.findOne({ email: email.toLowerCase() });
    
    // Sempre retornar sucesso por segurança
    res.json({
      success: true,
      message: 'Se o email existir, você receberá instruções de recuperação',
    });

    // Se usuário existe, enviar email (implementar serviço de email)
    if (user) {
      // TODO: Implementar envio de email
      console.log(`Email de recuperação para: ${user.email}`);
    }
  } catch (error) {
    console.error('Erro ao enviar email de recuperação:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500,
    });
  }
});

// GET /auth/verify
router.get('/verify', async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Token de acesso é obrigatório',
        statusCode: 401,
      });
    }

    const accessToken = authHeader.substring(7);
    
    // Verificar token
    const decoded = jwt.verify(accessToken, JWT_SECRET) as any;
    
    // Buscar sessão
    const session = await Session.findOne({
      accessToken,
      isActive: true,
      expiresAt: { $gt: new Date() },
    });

    if (!session) {
      return res.status(401).json({
        success: false,
        message: 'Token inválido ou expirado',
        statusCode: 401,
      });
    }

    // Buscar usuário
    const user = await User.findById(session.userId);
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Usuário não encontrado ou inativo',
        statusCode: 401,
      });
    }

    // Resposta
    const userResponse = {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      photo: user.photo,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
    };

    res.json({
      success: true,
      message: 'Token válido',
      data: {
        user: userResponse,
      },
    });
  } catch (error) {
    console.error('Erro ao verificar token:', error);
    res.status(401).json({
      success: false,
      message: 'Token inválido',
      statusCode: 401,
    });
  }
});

// PUT /auth/profile
router.put('/profile', async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Token de acesso é obrigatório',
        statusCode: 401,
      });
    }

    const accessToken = authHeader.substring(7);
    
    // Verificar token
    const decoded = jwt.verify(accessToken, JWT_SECRET) as any;
    
    // Buscar sessão
    const session = await Session.findOne({
      accessToken,
      isActive: true,
      expiresAt: { $gt: new Date() },
    });

    if (!session) {
      return res.status(401).json({
        success: false,
        message: 'Token inválido ou expirado',
        statusCode: 401,
      });
    }

    // Buscar usuário
    const user = await User.findById(session.userId);
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Usuário não encontrado ou inativo',
        statusCode: 401,
      });
    }

    // Atualizar campos permitidos
    const { name, photo } = req.body;
    if (name) user.name = name;
    if (photo !== undefined) user.photo = photo;
    
    user.updatedAt = new Date();
    await user.save();

    // Resposta
    const userResponse = {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      photo: user.photo,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
    };

    res.json({
      success: true,
      message: 'Perfil atualizado com sucesso',
      data: userResponse,
    });
  } catch (error) {
    console.error('Erro ao atualizar perfil:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500,
    });
  }
});

export default router;
