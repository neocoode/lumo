import mongoose, { Document, Schema } from "mongoose";

// Interface para configuração de slide individual
export interface ISlideConfig {
  activeIndex: number;
  selectedAnswer?: number;
  wasAnswered?: boolean;
}

// Interface para metadados do quiz
export interface IQuizMetadata {
  title: string;
  description: string;
  createdAt: Date;
  updatedAt: Date;
  difficulty?: string;
  author?: string;
}

// Interface para configurações dos slides
export interface ISlideConfigs {
  slides: ISlideConfig[];
  totalCorrect: number;
  totalWrong: number;
  totalQuestions: number;
  totalAnswered: number;
  accuracyPercent: number;
}

// Interface para pergunta
export interface ISlideQuestion {
  question: string;
  options: string[];
  correctAnswer: number;
  explanation: string;
  category: string;
  imagePath?: string;
}

// Interface para slide individual
export interface ISlideData {
  backgroundImage: string;
  backgroundColor: {
    value: number;
    hex: string;
  };
  question: ISlideQuestion;
}

// Interface principal do documento
export interface ISlideCollectionDocument extends Document {
  configs: {
    empty: ISlideConfigs;
    withAnswers: ISlideConfigs;
    title: string;
    description: string;
    date: Date;
    updatedAt: Date;
  };
  data: ISlideData[];
  categories: string[];
}

// Schema para configuração de slide
const SlideConfigSchema = new Schema<ISlideConfig>(
  {
    activeIndex: {
      type: Number,
      required: true,
      min: 0,
    },
    selectedAnswer: {
      type: Number,
      min: 0,
      max: 3,
    },
    wasAnswered: {
      type: Boolean,
      default: false,
    },
  },
  { _id: false }
);

// Schema para configurações dos slides
const SlideConfigsSchema = new Schema<ISlideConfigs>(
  {
    slides: {
      type: [SlideConfigSchema],
      required: true,
    },
    totalCorrect: {
      type: Number,
      required: true,
      min: 0,
    },
    totalWrong: {
      type: Number,
      required: true,
      min: 0,
    },
    totalQuestions: {
      type: Number,
      required: true,
      min: 0,
    },
    totalAnswered: {
      type: Number,
      required: true,
      min: 0,
    },
    accuracyPercent: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
  },
  { _id: false }
);

// Schema para pergunta
const QuestionSchema = new Schema<ISlideQuestion>(
  {
    question: {
      type: String,
      required: true,
      trim: true,
      maxlength: 500,
    },
    options: {
      type: [String],
      required: true,
      validate: {
        validator: function (options: string[]) {
          return options.length === 4;
        },
        message: "Deve ter exatamente 4 opções",
      },
    },
    correctAnswer: {
      type: Number,
      required: true,
      min: 0,
      max: 3,
    },
    explanation: {
      type: String,
      required: true,
      trim: true,
      maxlength: 1000,
    },
    category: {
      type: String,
      enum: [
        "geography",
        "science",
        "literature",
        "history",
        "mathematics",
        "biology",
      ],
      required: true,
    },
    imagePath: {
      type: String,
      trim: true,
    },
  },
  { _id: false }
);

// Schema para slide individual
const SlideDataSchema = new Schema<ISlideData>(
  {
    backgroundImage: {
      type: String,
      required: true,
      trim: true,
    },
    backgroundColor: {
      value: {
        type: Number,
        required: true,
      },
      hex: {
        type: String,
        required: true,
        match: /^#[0-9A-F]{6}$/i,
        message: "Cor deve estar no formato hexadecimal (#RRGGBB)",
      },
    },
    question: {
      type: QuestionSchema,
      required: true,
    },
  },
  { _id: false }
);

// Schema principal da collection
const SlidesCollectionSchema = new Schema<ISlideCollectionDocument>(
  {
    configs: {
      empty: {
        type: SlideConfigsSchema,
        required: true,
      },
      withAnswers: {
        type: SlideConfigsSchema,
        required: true,
      },
      title: {
        type: String,
        required: true,
        trim: true,
        maxlength: 100,
      },
      description: {
        type: String,
        required: true,
        trim: true,
        maxlength: 500,
      },
      date: {
        type: Date,
        required: true,
        default: Date.now,
      },
      updatedAt: {
        type: Date,
        required: true,
        default: Date.now,
      },
    },
    data: {
      type: [SlideDataSchema],
      required: true,
    },
    categories: {
      type: [String],
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

export const ChallengesCollectionModel = mongoose.model<ISlideCollectionDocument>(
  "ChallengesCollection",
  SlidesCollectionSchema,
  "challenges"
);
