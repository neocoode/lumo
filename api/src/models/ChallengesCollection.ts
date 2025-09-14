import mongoose, { Document, Schema, Types } from "mongoose";

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
  configs: {
    slideTime: number;
    allowSkip: boolean;
    showExplanation: boolean;
    difficulty: string;
    backgroundImage: string;
    backgroundColor: {
      value: number;
      hex: string;
    };
  };
  question: ISlideQuestion;
}

// Interface principal do documento
export interface ISlideCollectionDocument extends Document {
  userId: Types.ObjectId;
  configs: {
    title: string;
    description: string;
    date: Date;
    updatedAt: Date;
    // Configurações gerais do challenge
    slideTime?: number;
    totalTime?: number;
    allowSkip?: boolean;
    showExplanation?: boolean;
    randomizeQuestions?: boolean;
    difficulty?: string;
  };
  data: ISlideData[];
  categories: string[];
}

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
    configs: {
      slideTime: {
        type: Number,
        default: 30,
        min: 5,
        max: 300,
      },
      allowSkip: {
        type: Boolean,
        default: true,
      },
      showExplanation: {
        type: Boolean,
        default: true,
      },
      difficulty: {
        type: String,
        enum: ["easy", "medium", "hard"],
        default: "medium",
      },
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
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    configs: {
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
      // Configurações gerais do challenge
      slideTime: {
        type: Number,
        default: 30,
        min: 5,
        max: 300,
      },
      totalTime: {
        type: Number,
        default: 300,
        min: 30,
        max: 3600,
      },
      allowSkip: {
        type: Boolean,
        default: true,
      },
      showExplanation: {
        type: Boolean,
        default: true,
      },
      randomizeQuestions: {
        type: Boolean,
        default: false,
      },
      difficulty: {
        type: String,
        enum: ["easy", "medium", "hard"],
        default: "medium",
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

export const ChallengesCollectionModel =
  mongoose.model<ISlideCollectionDocument>(
    "ChallengesCollection",
    SlidesCollectionSchema,
    "challenges"
  );
