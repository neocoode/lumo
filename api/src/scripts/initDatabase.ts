import { MongoClient, Db } from "mongodb";
import { IMockData } from "../interfaces/mongo";
import { SlidesCollectionModel } from "../models/SlidesCollection";
import * as fs from "fs";
import * as path from "path";

// Configurações do banco
const MONGODB_URI =
  process.env.MONGODB_URI || "mongodb://admin:admin123@localhost:27017";
const DATABASE_NAME = "lumo";

// Função para log
function log(
  message: string,
  level: "INFO" | "SUCCESS" | "ERROR" | "WARNING" = "INFO"
) {
  const timestamp = new Date().toISOString();
  const colors = {
    INFO: "\x1b[36m", // Cyan
    SUCCESS: "\x1b[32m", // Green
    ERROR: "\x1b[31m", // Red
    WARNING: "\x1b[33m", // Yellow
  };
  const reset = "\x1b[0m";

  console.log(`${colors[level]}[${timestamp}] ${message}${reset}`);
}

// Função para carregar dados do arquivo JSON
async function loadInitData(): Promise<IMockData> {
  try {
    const dataPath = path.join(__dirname, "../../data/slides.json");
    const dataContent = fs.readFileSync(dataPath, "utf8");
    return JSON.parse(dataContent);
  } catch (error) {
    log(`Erro ao carregar dados de inicialização: ${error}`, "ERROR");
    throw error;
  }
}

// Função para verificar se o banco existe
async function checkDatabaseExists(client: MongoClient): Promise<boolean> {
  try {
    const adminDb = client.db().admin();
    const databases = await adminDb.listDatabases();
    return databases.databases.some((db: any) => db.name === DATABASE_NAME);
  } catch (error) {
    log(`Erro ao verificar existência do banco: ${error}`, "ERROR");
    return false;
  }
}

// Função para verificar se a collection slides existe e tem dados
async function checkSlidesCollection(
  db: Db
): Promise<{ exists: boolean; hasData: boolean; count: number }> {
  try {
    const collections = await db.listCollections().toArray();
    const slidesCollectionExists = collections.some(
      (col) => col.name === "slides"
    );

    if (!slidesCollectionExists) {
      return { exists: false, hasData: false, count: 0 };
    }

    const slidesCollection = db.collection("slides");
    const count = await slidesCollection.countDocuments();

    return {
      exists: true,
      hasData: count > 0,
      count,
    };
  } catch (error) {
    log(`Erro ao verificar collection slides: ${error}`, "ERROR");
    return { exists: false, hasData: false, count: 0 };
  }
}

// Função para inicializar dados no banco
async function initializeDatabaseData(
  db: Db,
  mockData: IMockData
): Promise<void> {
  try {
    log("Inicializando dados no banco...", "INFO");

    // Limpar dados existentes usando MongoDB nativo
    const slidesCollection = db.collection("slides");
    await slidesCollection.deleteMany({});
    log("Dados antigos removidos", "SUCCESS");

    // Criar novo documento com dados do mock
    const document = {
      configs: mockData.configs,
      data: mockData.data,
      categories: mockData.categories,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await slidesCollection.insertOne(document);
    log("Documento de slides inicializado com sucesso", "SUCCESS");

    // Mostrar estatísticas
    const total = mockData.data.length;
    const categories = mockData.categories;
    const byCategory: { [key: string]: number } = {};

    categories.forEach((category) => {
      byCategory[category] = mockData.data.filter(
        (slide) => slide.question.category === category
      ).length;
    });

    log(`Estatísticas:`, "INFO");
    log(`  Total de slides: ${total}`, "INFO");
    log(`  Categorias: ${categories.join(", ")}`, "INFO");
    log(`  Configurações: ${Object.keys(mockData.configs).length}`, "INFO");

    Object.entries(byCategory).forEach(([category, count]) => {
      log(`  ${category}: ${count} slides`, "INFO");
    });
  } catch (error) {
    log(`Erro ao inicializar dados: ${error}`, "ERROR");
    throw error;
  }
}

// Função principal
async function initializeDatabase(): Promise<void> {
  let client: MongoClient | null = null;

  try {
    log("🚀 Iniciando inicialização do banco de dados...", "INFO");

    // Conectar ao MongoDB
    log("Conectando ao MongoDB...", "INFO");
    client = new MongoClient(MONGODB_URI);
    await client.connect();
    log("Conectado ao MongoDB com sucesso", "SUCCESS");

    // Verificar se o banco existe
    const dbExists = await checkDatabaseExists(client);
    log(`Banco '${DATABASE_NAME}' existe: ${dbExists}`, "INFO");

    const db = client.db(DATABASE_NAME);

    // Verificar collection slides
    const slidesInfo = await checkSlidesCollection(db);
    log(`Collection 'slides' existe: ${slidesInfo.exists}`, "INFO");
    log(
      `Collection 'slides' tem dados: ${slidesInfo.hasData} (${slidesInfo.count} documentos)`,
      "INFO"
    );

    // Carregar dados de inicialização
    log("Carregando dados de inicialização...", "INFO");
    const initData = await loadInitData();
    log(
      `Dados de inicialização carregados: ${initData.data.length} slides`,
      "SUCCESS"
    );

    // Inicializar dados se necessário
    if (!slidesInfo.exists || !slidesInfo.hasData) {
      await initializeDatabaseData(db, initData);
    } else {
      log("Dados já existem no banco, pulando inicialização", "WARNING");
    }

    log("✅ Inicialização do banco concluída com sucesso!", "SUCCESS");
  } catch (error) {
    log(`❌ Erro durante inicialização: ${error}`, "ERROR");
    process.exit(1);
  } finally {
    if (client) {
      await client.close();
      log("Conexão com MongoDB fechada", "INFO");
    }
  }
}

// Executar se chamado diretamente
if (require.main === module) {
  initializeDatabase();
}

export { initializeDatabase };
