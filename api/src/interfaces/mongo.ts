// Interfaces MongoDB para challenges

export interface ISlideConfig {
  activeIndex: number;
  selectedAnswer?: number;
  wasAnswered?: boolean;
}

export interface ISlideConfigs {
  slides: ISlideConfig[];
  totalCorrect: number;
  totalWrong: number;
  totalQuestions: number;
  totalAnswered: number;
  accuracyPercent: number;
}

export interface ISlideQuestion {
  question: string;
  options: string[];
  correctAnswer: number;
  explanation: string;
  category: string;
  imagePath: string;
}

export interface ISlideData {
  backgroundImage: string;
  backgroundColor: {
    value: number;
    hex: string;
  };
  question: ISlideQuestion;
}

// Interface principal que representa o documento completo no MongoDB
export interface ISlideCollectionDocument {
  _id?: string;
  configs: {
    empty: ISlideConfigs;
    withAnswers: ISlideConfigs;
  };
  data: ISlideData[];
  categories: string[];
  createdAt?: Date;
  updatedAt?: Date;
}

// Interface para o arquivo JSON original
export interface IMockData {
  configs: {
    empty: ISlideConfigs;
    withAnswers: ISlideConfigs;
  };
  data: ISlideData[];
  categories: string[];
}

// Tipos para operações do banco
export type ICreateSlidesData = Omit<
  ISlideCollectionDocument,
  "_id" | "createdAt" | "updatedAt"
>;
export type IUpdateSlidesData = Partial<ICreateSlidesData>;
export type ISlidesQuery =
  | Partial<ISlideCollectionDocument>
  | { [key: string]: any };
