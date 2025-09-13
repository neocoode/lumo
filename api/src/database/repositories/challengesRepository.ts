import {
  ISlideCollectionDocument,
  ICreateSlidesData,
  IUpdateSlidesData,
  ISlidesQuery,
  IMockData,
} from "../../interfaces/mongo";
import {
  ChallengesCollectionModel,
  ISlideCollectionDocument as ISlideCollectionDocumentModel,
} from "../../models/ChallengesCollection";

export class ChallengesRepository {
  private collection: any;

  constructor(collection: any) {
    this.collection = collection;
  }

  // Criar documento completo de challenges
  async create(challengesData: ICreateSlidesData): Promise<ISlideCollectionDocument> {
    const result = await this.collection.insertOne({
      ...challengesData,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    return {
      _id: result.insertedId,
      ...challengesData,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }

  // Inicializar com dados do mock
  async initializeWithMockData(mockData: IMockData): Promise<ISlideCollectionDocument> {
    // Limpar dados existentes
    await this.deleteAll();

    // Criar novo documento com dados do mock
    const challengesData: ICreateSlidesData = {
      configs: mockData.configs,
      data: mockData.data,
      categories: mockData.categories,
    };

    return await this.create(challengesData);
  }

  // Buscar documento por ID
  async findById(id: string): Promise<ISlideCollectionDocument | null> {
    return await this.collection.findOne({ _id: id });
  }

  // Buscar o documento principal (deve haver apenas um)
  async findMain(): Promise<ISlideCollectionDocument | null> {
    return await this.collection.findOne({});
  }

  // Buscar todos os documentos
  async findAll(): Promise<ISlideCollectionDocument[]> {
    return await this.collection.find({}).toArray();
  }

  // Atualizar documento
  async update(
    id: string,
    updateData: IUpdateSlidesData
  ): Promise<ISlideCollectionDocument | null> {
    const result = await this.collection.findOneAndUpdate(
      { _id: id },
      {
        $set: {
          ...updateData,
          updatedAt: new Date(),
        },
      },
      { returnDocument: "after" }
    );

    return result.value;
  }

  // Atualizar o documento principal
  async updateMain(
    updateData: IUpdateSlidesData
  ): Promise<ISlideCollectionDocument | null> {
    const result = await this.collection.findOneAndUpdate(
      {},
      {
        $set: {
          ...updateData,
          updatedAt: new Date(),
        },
      },
      { returnDocument: "after" }
    );

    return result.value;
  }

  // Deletar documento por ID
  async delete(id: string): Promise<boolean> {
    const result = await this.collection.deleteOne({ _id: id });
    return result.deletedCount > 0;
  }

  // Deletar todos os documentos
  async deleteAll(): Promise<number> {
    const result = await this.collection.deleteMany({});
    return result.deletedCount;
  }

  // Contar documentos
  async count(query: ISlidesQuery = {}): Promise<number> {
    return await this.collection.countDocuments(query);
  }

  // Verificar se existe documento
  async exists(): Promise<boolean> {
    const count = await this.count();
    return count > 0;
  }

  // Buscar slides por categoria
  async getChallengesByCategory(category: string): Promise<any[]> {
    const mainDoc = await this.findMain();
    if (!mainDoc) return [];

    return mainDoc.data.filter((slide) => slide.question.category === category);
  }

  // Buscar todas as categorias
  async getCategories(): Promise<string[]> {
    const mainDoc = await this.findMain();
    return mainDoc ? mainDoc.categories : [];
  }

  // Buscar configurações vazias
  async getEmptyConfig(): Promise<any> {
    const mainDoc = await this.findMain();
    return mainDoc ? mainDoc.configs.empty : null;
  }

  // Buscar configurações com respostas
  async getWithAnswersConfig(): Promise<any> {
    const mainDoc = await this.findMain();
    return mainDoc ? mainDoc.configs.withAnswers : null;
  }

  // Buscar todos os slides (data)
  async getAllChallenges(): Promise<any[]> {
    const mainDoc = await this.findMain();
    return mainDoc ? mainDoc.data : [];
  }

  // Estatísticas dos challenges
  async getStats(): Promise<{
    total: number;
    byCategory: { [key: string]: number };
    categories: string[];
    totalConfigs: number;
  }> {
    const mainDoc = await this.findMain();

    if (!mainDoc) {
      return {
        total: 0,
        byCategory: {},
        categories: [],
        totalConfigs: 0,
      };
    }

    const total = mainDoc.data.length;
    const categories = mainDoc.categories;
    const byCategory: { [key: string]: number } = {};

    // Contar slides por categoria
    categories.forEach((category) => {
      byCategory[category] = mainDoc.data.filter(
        (slide) => slide.question.category === category
      ).length;
    });

    return {
      total,
      byCategory,
      categories,
      totalConfigs: Object.keys(mainDoc.configs).length,
    };
  }

  // Buscar slide específico por índice
  async getSlideByIndex(index: number): Promise<any | null> {
    const mainDoc = await this.findMain();
    if (!mainDoc || index < 0 || index >= mainDoc.data.length) {
      return null;
    }
    return mainDoc.data[index];
  }

  // Atualizar resposta de um slide específico
  async updateSlideAnswer(
    slideIndex: number,
    selectedAnswer: number
  ): Promise<boolean> {
    const mainDoc = await this.findMain();
    if (!mainDoc || slideIndex < 0 || slideIndex >= mainDoc.data.length) {
      return false;
    }

    // Atualizar a configuração withAnswers
    const updatePath = `configs.withAnswers.slides.${slideIndex}.selectedAnswer`;
    const wasAnsweredPath = `configs.withAnswers.slides.${slideIndex}.wasAnswered`;

    await this.collection.updateOne(
      {},
      {
        $set: {
          [updatePath]: selectedAnswer,
          [wasAnsweredPath]: true,
          updatedAt: new Date(),
        },
      }
    );

    return true;
  }
}
