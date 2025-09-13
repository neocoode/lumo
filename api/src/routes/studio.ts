import express from 'express';
import { StudioQuizModel, IStudioQuiz } from '../models/StudioQuiz';

const router = express.Router();

// Middleware de validação
const validateQuiz = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const { title, description, questions, config } = req.body;

  if (!title || title.trim().length < 3) {
    return res.status(400).json({
      success: false,
      message: 'Título deve ter pelo menos 3 caracteres',
      statusCode: 400
    });
  }

  if (!description || description.trim().length < 10) {
    return res.status(400).json({
      success: false,
      message: 'Descrição deve ter pelo menos 10 caracteres',
      statusCode: 400
    });
  }

  if (!questions || !Array.isArray(questions) || questions.length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Quiz deve ter pelo menos uma pergunta',
      statusCode: 400
    });
  }

  // Validar cada pergunta
  for (const question of questions) {
    if (!question.question || question.question.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Pergunta não pode estar vazia',
        statusCode: 400
      });
    }

    if (!question.options || !Array.isArray(question.options) || question.options.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Cada pergunta deve ter pelo menos 2 opções',
        statusCode: 400
      });
    }

    if (question.correctAnswer < 0 || question.correctAnswer >= question.options.length) {
      return res.status(400).json({
        success: false,
        message: 'Resposta correta deve ser um índice válido das opções',
        statusCode: 400
      });
    }

    if (!question.explanation || question.explanation.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Explicação não pode estar vazia',
        statusCode: 400
      });
    }
  }

  next();
};

// POST /api/studio/save - Salvar novo quiz
router.post('/save', validateQuiz, async (req: express.Request, res: express.Response) => {
  try {
    const { title, description, questions, config } = req.body;
    const authorId = req.body.authorId || 'anonymous'; // TODO: Implementar autenticação

    // Gerar IDs únicos para as perguntas
    const questionsWithIds = questions.map((question: any) => ({
      ...question,
      id: question.id || `q_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      createdAt: new Date(),
      updatedAt: new Date()
    }));

    const quiz = new StudioQuizModel({
      title: title.trim(),
      description: description.trim(),
      questions: questionsWithIds,
      config: {
        ...config,
        title: title.trim(),
        description: description.trim()
      },
      authorId,
      createdAt: new Date(),
      updatedAt: new Date()
    });

    const savedQuiz = await quiz.save();

    res.status(201).json({
      success: true,
      message: 'Quiz salvo com sucesso',
      data: savedQuiz,
      statusCode: 201
    });
  } catch (error) {
    console.error('Erro ao salvar quiz:', error);
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

    const quizzes = await StudioQuizModel
      .find({ authorId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();

    const total = await StudioQuizModel.countDocuments({ authorId });

    res.json({
      success: true,
      message: 'Quizzes carregados com sucesso',
      data: quizzes,
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

// GET /api/studio/quiz/:id - Obter quiz específico
router.get('/quiz/:id', async (req: express.Request, res: express.Response) => {
  try {
    const { id } = req.params;
    const authorId = req.query.authorId as string || 'anonymous'; // TODO: Implementar autenticação

    const quiz = await StudioQuizModel.findOne({ _id: id, authorId }).lean();

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: 'Quiz não encontrado',
        statusCode: 404
      });
    }

    res.json({
      success: true,
      message: 'Quiz carregado com sucesso',
      data: quiz,
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao obter quiz:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// PUT /api/studio/update/:id - Atualizar quiz
router.put('/update/:id', validateQuiz, async (req: express.Request, res: express.Response) => {
  try {
    const { id } = req.params;
    const { title, description, questions, config } = req.body;
    const authorId = req.body.authorId || 'anonymous'; // TODO: Implementar autenticação

    // Verificar se o quiz existe e pertence ao usuário
    const existingQuiz = await StudioQuizModel.findOne({ _id: id, authorId });
    if (!existingQuiz) {
      return res.status(404).json({
        success: false,
        message: 'Quiz não encontrado',
        statusCode: 404
      });
    }

    // Gerar IDs únicos para novas perguntas
    const questionsWithIds = questions.map((question: any) => ({
      ...question,
      id: question.id || `q_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      createdAt: question.createdAt || new Date(),
      updatedAt: new Date()
    }));

    const updatedQuiz = await StudioQuizModel.findByIdAndUpdate(
      id,
      {
        title: title.trim(),
        description: description.trim(),
        questions: questionsWithIds,
        config: {
          ...config,
          title: title.trim(),
          description: description.trim()
        },
        updatedAt: new Date()
      },
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Quiz atualizado com sucesso',
      data: updatedQuiz,
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao atualizar quiz:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// DELETE /api/studio/delete/:id - Deletar quiz
router.delete('/delete/:id', async (req: express.Request, res: express.Response) => {
  try {
    const { id } = req.params;
    const authorId = req.query.authorId as string || 'anonymous'; // TODO: Implementar autenticação

    const quiz = await StudioQuizModel.findOneAndDelete({ _id: id, authorId });

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: 'Quiz não encontrado',
        statusCode: 404
      });
    }

    res.json({
      success: true,
      message: 'Quiz deletado com sucesso',
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao deletar quiz:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

// GET /api/studio/stats - Obter estatísticas do usuário
router.get('/stats', async (req: express.Request, res: express.Response) => {
  try {
    const authorId = req.query.authorId as string || 'anonymous'; // TODO: Implementar autenticação

    const totalQuizzes = await StudioQuizModel.countDocuments({ authorId });
    
    const quizzes = await StudioQuizModel.find({ authorId }).lean();
    const totalQuestions = quizzes.reduce((sum, quiz) => sum + quiz.questions.length, 0);
    
    const categories = [...new Set(
      quizzes.flatMap(quiz => quiz.questions.map(q => q.category))
    )];

    res.json({
      success: true,
      message: 'Estatísticas carregadas com sucesso',
      data: {
        totalQuizzes,
        totalQuestions,
        categories,
        averageQuestionsPerQuiz: totalQuizzes > 0 ? Math.round(totalQuestions / totalQuizzes) : 0
      },
      statusCode: 200
    });
  } catch (error) {
    console.error('Erro ao obter estatísticas:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      statusCode: 500
    });
  }
});

export default router;
