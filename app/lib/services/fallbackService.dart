import 'dart:math';
import '../models/apiModels.dart';
import 'challengesApiService.dart';

class FallbackService implements IChallengesApiService {
  static final List<ISlideData> _fallbackSlides = [
    ISlideData(
      backgroundImage: "assets/images/geografia.svg",
      backgroundColor: "#4CAF50",
      question: ISlideQuestion(
        question: "Qual é a capital do Brasil?",
        options: ["São Paulo", "Rio de Janeiro", "Brasília", "Salvador"],
        correctAnswer: 2,
        explanation: "Brasília é a capital federal do Brasil desde 1960.",
        category: Categoria.geography,
        imagePath: "assets/images/geografia.svg",
      ),
    ),
    ISlideData(
      backgroundImage: "assets/images/ciencia.svg",
      backgroundColor: "#2196F3",
      question: ISlideQuestion(
        question: "Qual é o maior planeta do sistema solar?",
        options: ["Terra", "Saturno", "Júpiter", "Netuno"],
        correctAnswer: 2,
        explanation:
            "Júpiter é o maior planeta do sistema solar, com massa maior que todos os outros planetas juntos.",
        category: Categoria.science,
        imagePath: "assets/images/ciencia.svg",
      ),
    ),
    ISlideData(
      backgroundImage: "assets/images/literatura.svg",
      backgroundColor: "#FF9800",
      question: ISlideQuestion(
        question: "Quem escreveu 'Dom Casmurro'?",
        options: [
          "Machado de Assis",
          "José de Alencar",
          "Castro Alves",
          "Graciliano Ramos"
        ],
        correctAnswer: 0,
        explanation:
            "Machado de Assis é o autor de 'Dom Casmurro', publicado em 1899.",
        category: Categoria.literature,
        imagePath: "assets/images/literatura.svg",
      ),
    ),
    ISlideData(
      backgroundImage: "assets/images/historia.svg",
      backgroundColor: "#9C27B0",
      question: ISlideQuestion(
        question: "Em que ano o Brasil foi descoberto?",
        options: ["1498", "1500", "1502", "1504"],
        correctAnswer: 1,
        explanation:
            "O Brasil foi descoberto em 22 de abril de 1500 por Pedro Álvares Cabral.",
        category: Categoria.history,
        imagePath: "assets/images/historia.svg",
      ),
    ),
    ISlideData(
      backgroundImage: "assets/images/ciencia.svg",
      backgroundColor: "#00BCD4",
      question: ISlideQuestion(
        question: "Qual é a fórmula química da água?",
        options: ["H2O", "CO2", "NaCl", "O2"],
        correctAnswer: 0,
        explanation:
            "A água é composta por dois átomos de hidrogênio e um de oxigênio (H2O).",
        category: Categoria.science,
        imagePath: "assets/images/ciencia.svg",
      ),
    ),
  ];

  static final List<String> _categories = [
    'geography',
    'science',
    'literature',
    'history',
    'mathematics',
    'biology',
  ];

  @override
  Future<ISlideCollectionDocument> getChallenges() async {
    await _simulateDelay();

    final configs = ISlideConfigs(
      slides: _fallbackSlides.asMap().entries.map((entry) {
        return ISlideConfig(
          activeIndex: entry.key,
          selectedAnswer: null,
        );
      }).toList(),
      totalCorrect: 0,
      totalWrong: 0,
      totalQuestions: _fallbackSlides.length,
      totalAnswered: 0,
      accuracyPercentage: 0.0,
    );

    return ISlideCollectionDocument(
      data: _fallbackSlides,
      configs: configs,
      categories: _categories,
      title: 'Quiz',
      description: 'Quiz disponível offline',
      date: DateTime.now(),
    );
  }

  @override
  Future<List<String>> getCategories() async {
    await _simulateDelay();
    return _categories;
  }

  @override
  Future<List<ISlideData>> getChallengesByCategory(String category) async {
    await _simulateDelay();
    return _fallbackSlides.where((slide) {
      return slide.question.category.name.toLowerCase() ==
          category.toLowerCase();
    }).toList();
  }

  @override
  Future<ISlideData?> getSlideByIndex(int index) async {
    await _simulateDelay();
    if (index >= 0 && index < _fallbackSlides.length) {
      return _fallbackSlides[index];
    }
    return null;
  }

  @override
  Future<ISlideConfigs> getConfigsEmpty() async {
    await _simulateDelay();
    return ISlideConfigs(
      slides: _fallbackSlides.asMap().entries.map((entry) {
        return ISlideConfig(
          activeIndex: entry.key,
          selectedAnswer: null,
        );
      }).toList(),
      totalCorrect: 0,
      totalWrong: 0,
      totalQuestions: _fallbackSlides.length,
      totalAnswered: 0,
      accuracyPercentage: 0.0,
    );
  }

  @override
  Future<ISlideConfigs> getConfigsWithAnswers() async {
    await _simulateDelay();
    final random = Random();
    final slides = _fallbackSlides.asMap().entries.map((entry) {
      final hasAnswer = random.nextBool();
      return ISlideConfig(
        activeIndex: entry.key,
        selectedAnswer: hasAnswer ? random.nextInt(4) : null,
      );
    }).toList();

    final totalAnswered = slides.where((s) => s.selectedAnswer != null).length;
    final totalCorrect = slides.where((s) {
      if (s.selectedAnswer == null) return false;
      return s.selectedAnswer ==
          _fallbackSlides[s.activeIndex].question.correctAnswer;
    }).length;

    return ISlideConfigs(
      slides: slides,
      totalCorrect: totalCorrect,
      totalWrong: totalAnswered - totalCorrect,
      totalQuestions: _fallbackSlides.length,
      totalAnswered: totalAnswered,
      accuracyPercentage:
          totalAnswered > 0 ? (totalCorrect / totalAnswered) * 100 : 0.0,
    );
  }

  @override
  Future<bool> updateSlideAnswer(int index, int answer) async {
    await _simulateDelay();
    // Simulates success
    return true;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    await _simulateDelay();
    return {
      'totalSlides': _fallbackSlides.length,
      'totalCategories': _categories.length,
      'slidesByCategory': {
        for (String category in _categories)
          category: _fallbackSlides.where((slide) {
            return slide.question.category.name.toLowerCase() ==
                category.toLowerCase();
          }).length,
      },
    };
  }

  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(500)));
  }
}
