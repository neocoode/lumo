import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config();

const MONGODB_URI =
  process.env.MONGODB_URI || "mongodb://localhost:27017/meu_jogo";

export const connectDatabase = async (): Promise<void> => {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log("✅ Conectado ao MongoDB com sucesso!");

    // Configurações do Mongoose
    mongoose.set("strictQuery", true);

    // Event listeners
    mongoose.connection.on("error", (error) => {
      console.error("❌ Erro na conexão com MongoDB:", error);
    });

    mongoose.connection.on("disconnected", () => {
      console.log("⚠️ Desconectado do MongoDB");
    });

    mongoose.connection.on("reconnected", () => {
      console.log("🔄 Reconectado ao MongoDB");
    });
  } catch (error) {
    console.error("❌ Erro ao conectar com MongoDB:", error);
    process.exit(1);
  }
};

export const disconnectDatabase = async (): Promise<void> => {
  try {
    await mongoose.disconnect();
    console.log("✅ Desconectado do MongoDB");
  } catch (error) {
    console.error("❌ Erro ao desconectar do MongoDB:", error);
  }
};
