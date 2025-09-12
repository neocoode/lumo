import express from "express";
import { SlidesCollectionModel } from "../models/SlidesCollection";

const router = express.Router();

// GET /api/slides-local - Buscar documento principal de slides
router.get("/", async (req: any, res: any) => {
  console.log("📋 GET /api/slides - Buscando documento principal de slides");
  try {
    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
      });
    }

    console.log("✅ Documento principal encontrado com sucesso");
    res.json({
      success: true,
      data: mainDoc,
    });
  } catch (error) {
    console.error("❌ Erro ao buscar slides:", error);
    res.status(500).json({
      success: false,
      message: "Erro ao buscar slides",
      error: error instanceof Error ? error.message : "Erro desconhecido",
    });
  }
});

// GET /api/slides-local/categories - Buscar categorias
router.get("/categories", async (req: any, res: any) => {
  console.log("📂 GET /api/slides/categories - Buscando categorias");
  try {
    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

// GET /api/slides-local/category/:category - Buscar slides por categoria
router.get("/category/:category", async (req: any, res: any) => {
  const { category } = req.params;
  console.log(
    `🔍 GET /api/slides/category/${category} - Buscando slides por categoria`
  );
  try {
    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

// GET /api/slides-local/stats - Estatísticas dos slides
router.get("/stats", async (req: any, res: any) => {
  console.log("📊 GET /api/slides/stats - Buscando estatísticas dos slides");
  try {
    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

// GET /api/slides-local/paginated - Buscar slides com paginação
router.get("/paginated", async (req: any, res: any) => {
  console.log("📄 GET /api/slides/paginated - Buscando slides com paginação");
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const category = req.query.category as string;

    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

// GET /api/slides-local/slide/:index - Buscar slide por índice
router.get("/slide/:index", async (req: any, res: any) => {
  const { index } = req.params;
  console.log(`🎯 GET /api/slides/slide/${index} - Buscando slide por índice`);
  try {
    const slideIndex = parseInt(index);

    if (isNaN(slideIndex)) {
      return res.status(400).json({
        success: false,
        message: "Índice inválido",
      });
    }

    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

// GET /api/slides-local/configs/empty - Buscar configuração vazia
router.get("/configs/empty", async (req: any, res: any) => {
  console.log("⚙️ GET /api/slides/configs/empty - Buscando configuração vazia");
  try {
    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

// GET /api/slides-local/configs/with-answers - Buscar configuração com respostas
router.get("/configs/with-answers", async (req: any, res: any) => {
  console.log(
    "⚙️ GET /api/slides/configs/with-answers - Buscando configuração com respostas"
  );
  try {
    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

// PUT /api/slides-local/slide/:index/answer - Atualizar resposta de um slide
router.put("/slide/:index/answer", async (req: any, res: any) => {
  const { index } = req.params;
  const { selectedAnswer } = req.body;
  console.log(
    `✏️ PUT /api/slides/slide/${index}/answer - Atualizando resposta: ${selectedAnswer}`
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

    const mainDoc = await SlidesCollectionModel.findOne();

    if (!mainDoc) {
      return res.status(404).json({
        success: false,
        message: "Documento de slides não encontrado",
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

    await SlidesCollectionModel.updateOne(
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

// GET /api/slides-local/:id - Buscar documento por ID
router.get("/:id", async (req: any, res: any) => {
  const { id } = req.params;
  console.log(`🔍 GET /api/slides/${id} - Buscando documento por ID`);
  try {
    const document = await SlidesCollectionModel.findById(id);

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
