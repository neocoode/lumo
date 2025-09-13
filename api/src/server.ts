import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import rateLimit from "express-rate-limit";
import dotenv from "dotenv";

import { connectDatabase } from "./config/database";
import challengesRoutes from "./routes/challenges";
import studioRoutes from "./routes/studio";

// Carregar variáveis de ambiente
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de segurança
app.use(helmet());

// CORS
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "http://localhost:3000",
    credentials: true,
  })
);

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || "900000"), // 15 minutos
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || "100"), // 100 requests por IP
  message: {
    success: false,
    message: "Muitas requisições deste IP, tente novamente mais tarde.",
  },
});
app.use(limiter);

// Logging com Morgan
app.use(
  morgan(
    ":method :url :status :res[content-length] - :response-time ms :date[iso]"
  )
);

// Parser de JSON
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Rotas
app.use("/api/challenges", challengesRoutes);
app.use("/api/challenge", challengesRoutes);
app.use("/api/studio", studioRoutes);

// Rota de health check
app.get("/health", (req, res) => {
  res.json({
    success: true,
    message: "API funcionando corretamente",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development",
  });
});

// Rota raiz
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "API do Jogo de Quiz Educativo",
    version: "1.0.0",
    endpoints: {
      challenges: "/api/challenges",
      challenge: "/api/challenge",
      studio: "/api/studio",
      health: "/health",
    },
  });
});

// Middleware de tratamento de erros
app.use(
  (
    err: any,
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ) => {
    console.error("Erro não tratado:", err);

    res.status(err.status || 500).json({
      success: false,
      message: err.message || "Erro interno do servidor",
      error: process.env.NODE_ENV === "development" ? err : undefined,
    });
  }
);

// Middleware para rotas não encontradas
app.use("*", (req, res) => {
  res.status(404).json({
    success: false,
    message: "Rota não encontrada",
    path: req.originalUrl,
  });
});

// Inicializar servidor
const startServer = async () => {
  try {
    // Conectar ao MongoDB
    await connectDatabase();

    // Iniciar servidor
    app.listen(PORT, () => {
      console.log(`🚀 Servidor rodando na porta ${PORT}`);
      console.log(`📱 Ambiente: ${process.env.NODE_ENV || "development"}`);
      console.log(`🔗 URL: http://localhost:${PORT}`);
      console.log(`📊 Health Check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error("❌ Erro ao iniciar servidor:", error);
    process.exit(1);
  }
};

// Tratamento de sinais para shutdown graceful
process.on("SIGTERM", () => {
  console.log("🛑 SIGTERM recebido, encerrando servidor...");
  process.exit(0);
});

process.on("SIGINT", () => {
  console.log("🛑 SIGINT recebido, encerrando servidor...");
  process.exit(0);
});

// Iniciar aplicação
startServer();
