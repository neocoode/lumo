import express from "express";
import { ChallengesCollectionModel } from "../models/ChallengesCollection";

const router = express.Router();

// GET /api/challenges - Listar todos os challenges
router.get("/", async (req: any, res: any) => {
  console.log("📋 GET /api/challenges - Listando todos os challenges");
  try {
    const challenges = await ChallengesCollectionModel.find().sort({ 'configs.updatedAt': -1 });

    if (!challenges || challenges.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Nenhum challenge encontrado",
      });
    }

    console.log(`✅ ${challenges.length} challenges encontrados`);
    res.json({
      success: true,
      data: challenges,
      total: challenges.length,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar challenges:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar challenges",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenge - Retornar resultado completo do banco encontrado (endpoint legado)
router.get("/challenge", async (req: any, res: any) => {
  console.log("📋 GET /api/challenge - Retornando resultado completo do banco");
  try {
    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    console.log("📊 Resultado completo do banco encontrado:");
    console.log("  - ID:", mainDoc._id);
    console.log("  - Title (configs):", mainDoc.configs.title);
    console.log("  - Description (configs):", mainDoc.configs.description);
    console.log("  - Date (configs):", mainDoc.configs.date);
    console.log("  - Data length:", mainDoc.data.length);
    console.log("  - Categories:", mainDoc.categories);
    console.log("✅ Resultado completo do banco retornado com sucesso");
    
    res.json({
      success: true,
      data: mainDoc,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar resultado do banco:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar resultado do banco",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});



// GET /api/challenges/categories - Buscar categorias
router.get("/categories", async (req: any, res: any) => {
  console.log("📂 GET /api/challenges/categories - Buscando categorias");
  try {
    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    console.log(`✅ Categorias encontradas: ${mainDoc.categories.length}`);
    res.json({
      success: true,
      data: mainDoc.categories,
      count: mainDoc.categories.length,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar categorias:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar categorias",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenges/category/:category - Buscar slides por categoria
router.get("/category/:category", async (req: any, res: any) => {
  const { category } = req.params;
  console.log(
    `🔍 GET /api/challenges/category/${category} - Buscando slides por categoria`
  );
  try {
    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    const slides = mainDoc.data.filter(
      (slide) => slide.question.category === category
    );

    console.log(
      `✅ Slides encontrados para categoria ${category}: ${slides.length}`
    );
    res.json({
      success: true,
      data: slides,
      count: slides.length,
      category,
    });
  } catch (error) {
    console.error(`❌ Erro ao buscar slides por categoria ${category}:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar slides por categoria",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenges/stats - Estatísticas dos slides
router.get("/stats", async (req: any, res: any) => {
  console.log("📊 GET /api/challenges/stats - Buscando estatísticas dos slides");
  try {
    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    const total = mainDoc.data.length;
    const categories = mainDoc.categories;
    const byCategory: { [key: string]: number } = {};

    categories.forEach((category) => {
      byCategory[category] = mainDoc.data.filter(
        (slide) => slide.question.category === category
      ).length;
    });

    const stats = {
      total,
      byCategory,
      categories,
      totalConfigs: Object.keys(mainDoc.configs).length,
    };

    console.log(
      `✅ Estatísticas geradas: ${stats.total} slides, ${stats.categories.length} categorias`
    );
    res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar estatísticas:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar estatísticas",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenges/paginated - Buscar slides com paginação
router.get("/paginated", async (req: any, res: any) => {
  console.log("📄 GET /api/challenges/paginated - Buscando slides com paginação");
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const category = req.query.category as string;

    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    let slides = mainDoc.data;

    // Filtrar por categoria se especificada
    if (category) {
      slides = slides.filter((slide) => slide.question.category === category);
    }

    // Paginação
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const paginatedSlides = slides.slice(startIndex, endIndex);

    const result = {
      slides: paginatedSlides,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(slides.length / limit),
        totalItems: slides.length,
        itemsPerPage: limit,
        hasNextPage: endIndex < slides.length,
        hasPrevPage: page > 1,
      },
    };

    console.log(
      `✅ Slides paginados encontrados: ${paginatedSlides.length} de ${slides.length}`
    );
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar slides paginados:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar slides paginados",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenges/slide/:index - Buscar slide por índice
router.get("/slide/:index", async (req: any, res: any) => {
  const { index } = req.params;
  console.log(`🎯 GET /api/challenges/slide/${index} - Buscando slide por índice`);
  try {
    const slideIndex = parseInt(index);

    if (isNaN(slideIndex)) {
      return res.status(400).json({
        success: false,
        message: "Índice inválido",
      });
    }

    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    if (slideIndex < 0 || slideIndex >= mainDoc.data.length) {
      return res.status(404).json({
        success: false,
        message: "Slide não encontrado",
      });
    }

    const slide = mainDoc.data[slideIndex];

    console.log(`✅ Slide encontrado no índice ${slideIndex}`);
    res.json({
      success: true,
      data: slide,
      index: slideIndex,
    });
  } catch (error) {
    console.error(`❌ Erro ao buscar slide no índice ${index}:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar slide",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenges/configs/empty - Buscar configuração vazia
router.get("/configs/empty", async (req: any, res: any) => {
  console.log("⚙️ GET /api/challenges/configs/empty - Buscando configuração vazia");
  try {
    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    console.log("✅ Configuração vazia encontrada");
    res.json({
      success: true,
      data: mainDoc.configs.empty,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar configuração vazia:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar configuração vazia",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenges/configs/with-answers - Buscar configuração com respostas
router.get("/configs/with-answers", async (req: any, res: any) => {
  console.log(
    "⚙️ GET /api/challenges/configs/with-answers - Buscando configuração com respostas"
  );
  try {
    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    console.log("✅ Configuração com respostas encontrada");
    res.json({
      success: true,
      data: mainDoc.configs.withAnswers,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar configuração com respostas:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar configuração com respostas",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// PUT /api/challenges/slide/:index/answer - Atualizar resposta de um slide
router.put("/slide/:index/answer", async (req: any, res: any) => {
  const { index } = req.params;
  const { selectedAnswer } = req.body;
  console.log(
    `✏️ PUT /api/challenges/slide/${index}/answer - Atualizando resposta: ${selectedAnswer}`
  );
  try {
    const slideIndex = parseInt(index);

    if (isNaN(slideIndex)) {
      return res.status(400).json({
        success: false,
        message: "Índice inválido",
      });
    }

    if (selectedAnswer === undefined || selectedAnswer === null) {
      return res.status(400).json({
        success: false,
        message: "Resposta selecionada é obrigatória",
      });
    }

    const mainDoc = await ChallengesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de challenges não encontrado",
      });
    }

    if (slideIndex < 0 || slideIndex >= mainDoc.data.length) {
      return res.status(404).json({
        success: false,
        message: "Slide não encontrado ou índice inválido",
      });
    }

    // Atualizar a configuração withAnswers
    const updatePath = `configs.withAnswers.slides.${slideIndex}.selectedAnswer`;
    const wasAnsweredPath = `configs.withAnswers.slides.${slideIndex}.wasAnswered`;

    await ChallengesCollectionModel.updateOne(
      {},
      {
        $set: {
          [updatePath]: selectedAnswer,
          [wasAnsweredPath]: true,
        },
      }
    );

    console.log(
      `✅ Resposta atualizada com sucesso para slide ${slideIndex}: ${selectedAnswer}`
    );
    res.json({
      success: true,
      message: "Resposta atualizada com sucesso",
      data: {
        slideIndex,
        selectedAnswer,
      },
    });
  } catch (error) {
    console.error(`❌ Erro ao atualizar resposta do slide ${index}:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao atualizar resposta",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// POST /api/studio/save - Endpoint unificado para criar/editar challenges do Studio
router.post("/studio/save", async (req: any, res: any) => {
  console.log("🎨 POST /api/studio/save - Salvando challenge do Studio");
  try {
    const {
      id,
      title,
      description,
      category,
      questions,
      slideTime,
      totalTime,
      allowSkip,
      showExplanation,
      randomizeQuestions,
      difficulty,
    } = req.body;

    // Validar dados obrigatórios
    if (!title || !description || !questions || !Array.isArray(questions)) {
      return res.status(400).json({
        success: false,
        message: "Dados obrigatórios: title, description, questions",
      });
    }

    // Validar se as perguntas têm dados válidos
    if (questions.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Pelo menos uma pergunta é obrigatória",
      });
    }

    // Converter perguntas para o formato esperado
    const slidesData = questions.map((question: any) => ({
      backgroundImage: "assets/images/default.svg",
      backgroundColor: {
        hex: "#667eea",
        value: 0x667eea,
      },
      question: {
        question: question.question || "",
        options: question.options || [],
        correctAnswer: question.correctAnswer || 0,
        explanation: question.explanation || "",
        category: question.category || category,
        imagePath: question.imagePath || null,
      },
    }));

    let result;
    const isUpdate = id && id.trim() !== "";

    if (isUpdate) {
      // Atualizar challenge existente
      console.log(`✏️ Atualizando challenge existente: ${id}`);
      
      // Verificar se o challenge existe
      const existingChallenge = await ChallengesCollectionModel.findById(id);
      if (!existingChallenge) {
        return res.status(404).json({
          success: false,
          message: "Challenge não encontrado para atualização",
        });
      }

      result = await ChallengesCollectionModel.findByIdAndUpdate(
        id,
        {
          data: slidesData,
          "configs.title": title,
          "configs.description": description,
          "configs.updatedAt": new Date().toISOString(),
          "configs.slideTime": slideTime || 30,
          "configs.totalTime": totalTime || 300,
          "configs.allowSkip": allowSkip !== undefined ? allowSkip : true,
          "configs.showExplanation": showExplanation !== undefined ? showExplanation : true,
          "configs.randomizeQuestions": randomizeQuestions !== undefined ? randomizeQuestions : false,
          "configs.difficulty": difficulty || "medium",
          "configs.empty.slides": slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null })),
          "configs.empty.totalQuestions": slidesData.length,
          "configs.empty.totalCorrect": 0,
          "configs.empty.totalWrong": 0,
          "configs.empty.totalAnswered": 0,
          "configs.empty.accuracyPercentage": 0,
          "configs.empty.accuracyPercent": 0,
          "configs.withAnswers.slides": slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null, wasAnswered: false })),
          "configs.withAnswers.totalQuestions": slidesData.length,
          "configs.withAnswers.totalCorrect": 0,
          "configs.withAnswers.totalWrong": 0,
          "configs.withAnswers.totalAnswered": 0,
          "configs.withAnswers.accuracyPercentage": 0,
          "configs.withAnswers.accuracyPercent": 0,
          categories: [category],
        },
        { new: true, runValidators: true }
      );

      console.log(`✅ Challenge atualizado com sucesso: ${id}`);
    } else {
      // Criar novo challenge
      console.log("➕ Criando novo challenge");
      const newChallenge = new ChallengesCollectionModel({
        data: slidesData,
        configs: {
          title: title,
          description: description,
          date: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          slideTime: slideTime || 30,
          totalTime: totalTime || 300,
          allowSkip: allowSkip !== undefined ? allowSkip : true,
          showExplanation: showExplanation !== undefined ? showExplanation : true,
          randomizeQuestions: randomizeQuestions !== undefined ? randomizeQuestions : false,
          difficulty: difficulty || "medium",
          empty: {
            slides: slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null })),
            totalCorrect: 0,
            totalWrong: 0,
            totalQuestions: slidesData.length,
            totalAnswered: 0,
            accuracyPercentage: 0,
            accuracyPercent: 0,
          },
          withAnswers: {
            slides: slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null, wasAnswered: false })),
            totalCorrect: 0,
            totalWrong: 0,
            totalQuestions: slidesData.length,
            totalAnswered: 0,
            accuracyPercentage: 0,
            accuracyPercent: 0,
          },
        },
        categories: [category],
      });

      result = await newChallenge.save();
      console.log(`✅ Challenge criado com sucesso: ${result._id}`);
    }

    if (!result) {
      return res.status(500).json({
        success: false,
        message: "Erro interno: resultado não encontrado",
      });
    }

    res.json({
      success: true,
      message: isUpdate ? "Challenge atualizado com sucesso" : "Challenge criado com sucesso",
      data: {
        id: result._id,
        title: result.configs.title,
        description: result.configs.description,
        category: result.categories[0],
        questionsCount: result.data.length,
        createdAt: result.configs.date,
        updatedAt: result.configs.updatedAt,
        isUpdate: isUpdate,
      },
    });
  } catch (error) {
    console.error("❌ Erro ao salvar challenge do Studio:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao salvar challenge",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// POST /api/challenges - Criar novo challenge
router.post("/", async (req: any, res: any) => {
  console.log("➕ POST /api/challenges - Criando novo challenge");
  try {
    const {
      title,
      description,
      category,
      questions,
      slideTime,
      totalTime,
      allowSkip,
      showExplanation,
      randomizeQuestions,
      difficulty,
    } = req.body;

    // Validar dados obrigatórios
    if (!title || !description || !questions || !Array.isArray(questions)) {
      return res.status(400).json({
        success: false,
        message: "Dados obrigatórios: title, description, questions",
      });
    }

    // Converter perguntas para o formato esperado
    const slidesData = questions.map((question: any) => ({
      backgroundImage: "assets/images/default.svg",
      backgroundColor: {
        hex: "#667eea",
        value: 0x667eea,
      },
      question: {
        question: question.question,
        options: question.options,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        category: question.category,
        imagePath: question.imagePath,
      },
    }));

    // Criar novo documento
    const newChallenge = new ChallengesCollectionModel({
      data: slidesData,
      configs: {
        title: title,
        description: description,
        date: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        slideTime: slideTime || 30,
        totalTime: totalTime || 300,
        allowSkip: allowSkip !== undefined ? allowSkip : true,
        showExplanation: showExplanation !== undefined ? showExplanation : true,
        randomizeQuestions: randomizeQuestions !== undefined ? randomizeQuestions : false,
        difficulty: difficulty || "medium",
        empty: {
          slides: slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null })),
          totalCorrect: 0,
          totalWrong: 0,
          totalQuestions: slidesData.length,
          totalAnswered: 0,
          accuracyPercentage: 0,
        },
        withAnswers: {
          slides: slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null, wasAnswered: false })),
          totalCorrect: 0,
          totalWrong: 0,
          totalQuestions: slidesData.length,
          totalAnswered: 0,
          accuracyPercentage: 0,
        },
      },
      categories: [category],
    });

    const savedChallenge = await newChallenge.save();

    console.log(`✅ Challenge criado com sucesso: ${savedChallenge._id}`);
    res.status(201).json({
      success: true,
      message: "Challenge criado com sucesso",
      data: savedChallenge,
    });
  } catch (error) {
    console.error("❌ Erro ao criar challenge:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao criar challenge",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// PUT /api/challenges/:id - Atualizar challenge existente
router.put("/:id", async (req: any, res: any) => {
  const { id } = req.params;
  console.log(`✏️ PUT /api/challenges/${id} - Atualizando challenge`);
  try {
    const {
      title,
      description,
      category,
      questions,
      slideTime,
      totalTime,
      allowSkip,
      showExplanation,
      randomizeQuestions,
      difficulty,
    } = req.body;

    // Validar dados obrigatórios
    if (!title || !description || !questions || !Array.isArray(questions)) {
      return res.status(400).json({
        success: false,
        message: "Dados obrigatórios: title, description, questions",
      });
    }

    // Converter perguntas para o formato esperado
    const slidesData = questions.map((question: any) => ({
      backgroundImage: "assets/images/default.svg",
      backgroundColor: {
        hex: "#667eea",
        value: 0x667eea,
      },
      question: {
        question: question.question,
        options: question.options,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        category: question.category,
        imagePath: question.imagePath,
      },
    }));

    // Atualizar documento
    const updatedChallenge = await ChallengesCollectionModel.findByIdAndUpdate(
      id,
      {
        data: slidesData,
        "configs.title": title,
        "configs.description": description,
        "configs.updatedAt": new Date().toISOString(),
        "configs.slideTime": slideTime || 30,
        "configs.totalTime": totalTime || 300,
        "configs.allowSkip": allowSkip !== undefined ? allowSkip : true,
        "configs.showExplanation": showExplanation !== undefined ? showExplanation : true,
        "configs.randomizeQuestions": randomizeQuestions !== undefined ? randomizeQuestions : false,
        "configs.difficulty": difficulty || "medium",
        "configs.empty.slides": slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null })),
        "configs.empty.totalQuestions": slidesData.length,
        "configs.withAnswers.slides": slidesData.map(() => ({ activeIndex: 0, selectedAnswer: null, wasAnswered: false })),
        "configs.withAnswers.totalQuestions": slidesData.length,
        categories: [category],
      },
      { new: true, runValidators: true }
    );

    if (!updatedChallenge) {
      return res.status(404).json({
        success: false,
        message: "Challenge não encontrado",
      });
    }

    console.log(`✅ Challenge atualizado com sucesso: ${id}`);
    res.json({
      success: true,
      message: "Challenge atualizado com sucesso",
      data: updatedChallenge,
    });
  } catch (error) {
    console.error(`❌ Erro ao atualizar challenge ${id}:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao atualizar challenge",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/challenges/:id - Buscar documento por ID
router.get("/:id", async (req: any, res: any) => {
  const { id } = req.params;
  console.log(`🔍 GET /api/challenges/${id} - Buscando documento por ID`);
  try {
    const document = await ChallengesCollectionModel.findById(id);

    if (!document) {
      return res.status(404).json({
        success: false,
        message: "Documento não encontrado",
      });
    }

    console.log(`✅ Documento encontrado com ID: ${id}`);
    res.json({
      success: true,
      data: document,
    });
  } catch (error) {
    console.error(`❌ Erro ao buscar documento com ID ${id}:`, error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar documento",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

export default router;
