import express from 'express';
import { ChallengesCollectionModel, ISlideCollectionDocument } from '../models/ChallengesCollection';
import { Types } from 'mongoose';

const router = express.Router();

// Middleware de validação
const validateQuiz = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.log('=== VALIDATE QUIZ ===');
  console.log('Request body:', JSON.stringify(req.body, null, 2));
  
  const { title, description, questions, config } = req.body;

  if (!title || title.trim().length < 3) {
    console.log('❌ Validação falhou: Título muito curto');
    return res.status(400).json({
      success: false,
      message: 'Título deve ter pelo menos 3 caracteres',
      statusCode: 400
    });
  }

  if (!description || description.trim().length < 10) {
    console.log('❌ Validação falhou: Descrição muito curta');
    return res.status(400).json({
      success: false,
      message: 'Descrição deve ter pelo menos 10 caracteres',
      statusCode: 400
    });
  }

  if (!questions || !Array.isArray(questions) || questions.length === 0) {
    console.log('❌ Validação falhou: Nenhuma pergunta encontrada');
    return res.status(400).json({
      success: false,
      message: 'Quiz deve ter pelo menos uma pergunta',
      statusCode: 400
    });
  }

  // Validar cada pergunta
  console.log(`Validando ${questions.length} perguntas...`);
  for (let i = 0; i < questions.length; i++) {
    const question = questions[i];
    const questionData = question.data; // Acessar os dados aninhados
    
    console.log(`Validando pergunta ${i + 1}:`, {
      hasQuestion: !!questionData?.question,
      questionLength: questionData?.question?.trim().length || 0,
      hasOptions: !!questionData?.options,
      optionsLength: questionData?.options?.length || 0,
      correctAnswer: questionData?.correctAnswer,
      hasExplanation: !!questionData?.explanation,
      explanationLength: questionData?.explanation?.trim().length || 0
    });

    if (!questionData?.question || questionData.question.trim().length === 0) {
      console.log(`❌ Validação falhou: Pergunta ${i + 1} está vazia`);
      return res.status(400).json({
        success: false,
        message: 'Pergunta não pode estar vazia',
        statusCode: 400
      });
    }

    if (!questionData?.options || !Array.isArray(questionData.options) || questionData.options.length < 2) {
      console.log(`❌ Validação falhou: Pergunta ${i + 1} tem menos de 2 opções`);
      return res.status(400).json({
        success: false,
        message: 'Cada pergunta deve ter pelo menos 2 opções',
        statusCode: 400
      });
    }

    if (questionData.correctAnswer < 0 || questionData.correctAnswer >= questionData.options.length) {
      console.log(`❌ Validação falhou: Pergunta ${i + 1} tem resposta correta inválida`);
      return res.status(400).json({
        success: false,
        message: 'Resposta correta deve ser um índice válido das opções',
        statusCode: 400
      });
    }

    if (!questionData?.explanation || questionData.explanation.trim().length === 0) {
      console.log(`❌ Validação falhou: Pergunta ${i + 1} não tem explicação`);
      return res.status(400).json({
        success: false,
        message: 'Explicação não pode estar vazia',
        statusCode: 400
      });
    }
  }

  console.log('✅ Validação passou com sucesso!');
  next();
};

// POST /api/studio/save - Salvar novo quiz
router.post('/save', validateQuiz, async (req: express.Request, res: express.Response) => {
  try {
    console.log('=== POST /api/studio/save ===');
    console.log('Request body:', JSON.stringify(req.body, null, 2));
    
    const { title, description, questions, config } = req.body;
    const authorId = req.body.authorId || 'anonymous'; // TODO: Implementar autenticação
    
    console.log('Extracted data:', {
      title,
      description,
      questionsCount: questions?.length,
      config,
      authorId
    });

    // Processar e transformar as perguntas para o formato do ChallengesCollection
    const slideData = questions.map((question: any) => {
      // Se a pergunta tem estrutura aninhada (question.data), extrair os dados
      const questionData = question.data || question;
      
      return {
        configs: {
          slideTime: config.timePerQuestion || 30,
          allowSkip: true,
          showExplanation: config.showExplanation || true,
          difficulty: 'medium',
          backgroundImage: config.backgroundImage || 'assets/images/default.svg',
          backgroundColor: {
            value: parseInt((config.backgroundColor || '#667eea').replace('#', ''), 16),
            hex: config.backgroundColor || '#667eea'
          }
        },
        question: {
          question: questionData.question,
          options: questionData.options,
          correctAnswer: questionData.correctAnswer,
          explanation: questionData.explanation,
          category: questionData.category,
          imagePath: questionData.imagePath || null
        }
      };
    });

    // Extrair categorias únicas das perguntas
    const categories = [...new Set(questions.map((q: any) => {
      const questionData = q.data || q;
      return questionData.category;
    }))];

    // Criar um ObjectId válido para o userId
    const userId = authorId === 'anonymous' ? new Types.ObjectId() : new Types.ObjectId(authorId);
    
    const challenge = new ChallengesCollectionModel({
      userId: userId,
      configs: {
        title: title.trim(),
        description: description.trim(),
        date: new Date(),
        updatedAt: new Date(),
        slideTime: config.timePerQuestion || 30,
        totalTime: (config.timePerQuestion || 30) * questions.length,
        allowSkip: true,
        showExplanation: config.showExplanation || true,
        randomizeQuestions: config.shuffleQuestions || false,
        difficulty: 'medium'
      },
      data: slideData,
      categories: categories
    });

    console.log('Tentando salvar challenge no banco...');
    const savedChallenge = await challenge.save();
    console.log('Challenge salvo com sucesso:', savedChallenge._id);

    res.status(201).json({
      success: true,
      message: 'Challenge salvo com sucesso',
      data: savedChallenge,
      statusCode: 201
    });
  } catch (error) {
    console.error('=== ERRO ao salvar quiz ===');
    console.error('Error details:', error);
    console.error('Error message:', error instanceof Error ? error.message : 'Unknown error');
    console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
    
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// GET /api/studio/list - Listar quizzes do usuário
router.get('/list', async (req: express.Request, res: express.Response) => {
  try {
    const authorId = req.query.authorId as string || 'anonymous'; // TODO: Implementar autenticação
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;

    console.log(`📋 GET /api/studio/list - Listando quizzes para authorId: ${authorId}`);

    // Para listagem, vamos buscar todos os challenges se authorId for 'anonymous'
    const query = authorId === 'anonymous' ? {} : { userId: new Types.ObjectId(authorId) };
    
    const challenges = await ChallengesCollectionModel
      .find(query)
      .sort({ 'configs.updatedAt': -1 })
      .skip(skip)
      .limit(limit)
      .lean();
      console.log('📊 Challenges encontrados:', challenges);

    const total = await ChallengesCollectionModel.countDocuments(query);

    console.log(`📊 Encontrados ${challenges.length} challenges para ${authorId} (total: ${total})`);

    res.json({
      success: true,
      message: 'Challenges carregados com sucesso',
      data: challenges,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      },
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao listar quizzes:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// GET /api/studio/debug/all - Debug: Listar todos os challenges (temporário)
router.get('/debug/all', async (req: express.Request, res: express.Response) => {
  try {
    console.log('🔍 GET /api/studio/debug/all - Listando todos os challenges para debug');

    const allChallenges = await ChallengesCollectionModel.find({}).lean();
    
    console.log(`📊 Total de challenges no banco: ${allChallenges.length}`);
    
    const challengeSummary = allChallenges.map(challenge => ({
      _id: challenge._id,
      title: challenge.configs.title,
      userId: challenge.userId,
      questionsCount: challenge.data?.length || 0,
      createdAt: challenge.configs.date
    }));

    res.json({
      success: true,
      message: 'Todos os challenges listados para debug',
      data: {
        total: allChallenges.length,
        challenges: challengeSummary
      },
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao listar todos os challenges:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// GET /api/studio/quiz/:id - Obter challenge específico
router.get('/quiz/:id', async (req: express.Request, res: express.Response) => {
  try {
    const { id } = req.params;
    const authorId = req.query.authorId as string || 'anonymous'; // TODO: Implementar autenticação

    // Para busca específica, vamos buscar por ID apenas se authorId for 'anonymous'
    const query = authorId === 'anonymous' ? { _id: id } : { _id: id, userId: new Types.ObjectId(authorId) };
    const challenge = await ChallengesCollectionModel.findOne(query).lean();

    if (!challenge) {
      return res.status(404).json({
        success: false,
        message: 'Challenge não encontrado',
        statusCode: 404
      });
    }

    res.json({
      success: true,
      message: 'Challenge carregado com sucesso',
      data: challenge,
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao obter challenge:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// GET /api/studio/preview/:id - Preview de quiz para execução
router.get('/preview/:id', async (req: express.Request, res: express.Response) => {
  try {
    const { id } = req.params;
    const authorId = req.query.authorId as string || 'anonymous'; // TODO: Implementar autenticação

    console.log(`🎮 GET /api/studio/preview/${id} - Preview de quiz para execução`);
    console.log(`🔍 Buscando quiz com ID: ${id} e authorId: ${authorId}`);

    // Primeiro, vamos verificar se o challenge existe sem filtro de authorId
    const challengeWithoutAuthor = await ChallengesCollectionModel.findById(id).lean();
    console.log(`📊 Challenge encontrado sem filtro de author:`, challengeWithoutAuthor ? 'SIM' : 'NÃO');
    
    if (challengeWithoutAuthor) {
      console.log(`📋 Challenge details:`, {
        _id: challengeWithoutAuthor._id,
        title: challengeWithoutAuthor.configs.title,
        userId: challengeWithoutAuthor.userId,
        questionsCount: challengeWithoutAuthor.data?.length || 0
      });
    }

    // Agora buscar com filtro de authorId
    const query = authorId === 'anonymous' ? { _id: id } : { _id: id, userId: new Types.ObjectId(authorId) };
    const challenge = await ChallengesCollectionModel.findOne(query).lean();
    console.log(`📊 Challenge encontrado com filtro de author:`, challenge ? 'SIM' : 'NÃO');

    if (!challenge) {
      // Se não encontrou com authorId, vamos tentar sem o filtro para debug
      if (challengeWithoutAuthor) {
        console.log(`⚠️ Challenge existe mas com userId diferente. Challenge userId: ${challengeWithoutAuthor.userId}, Requested authorId: ${authorId}`);
        return res.status(404).json({
          success: false,
          message: `Challenge não encontrado para o usuário. Challenge pertence ao userId: ${challengeWithoutAuthor.userId}`,
          statusCode: 404
        });
      } else {
        console.log(`❌ Challenge não existe no banco de dados`);
        return res.status(404).json({
          success: false,
          message: 'Challenge não encontrado',
          statusCode: 404
        });
      }
    }

    // Transformar dados do ChallengesCollection para formato esperado pelo frontend
    const transformedData = {
      _id: challenge._id,
      userId: challenge.userId,
      configs: {
        title: challenge.configs.title,
        description: challenge.configs.description,
        date: challenge.configs.date,
        updatedAt: challenge.configs.updatedAt,
        slides: challenge.data.map((slide, index) => ({
          activeIndex: index,
          selectedAnswer: null,
        })),
        totalCorrect: 0,
        totalWrong: 0,
        totalQuestions: challenge.data.length,
        totalAnswered: 0,
        accuracyPercentage: 0.0,
      },
      data: challenge.data,
      categories: challenge.categories,
      createdAt: challenge.configs.date,
      updatedAt: challenge.configs.updatedAt
    };

    console.log(`✅ Challenge transformado para preview: ${challenge.data.length} perguntas`);

    res.json({
      success: true,
      message: 'Preview do quiz carregado com sucesso',
      data: transformedData,
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao obter preview do quiz:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// Endpoint removido - agora usando ChallengesCollection

// Endpoint removido - agora usando ChallengesCollection

// Endpoint removido - agora usando ChallengesCollection

export default router;
