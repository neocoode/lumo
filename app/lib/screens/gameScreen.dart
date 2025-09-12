import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../models/apiModels.dart';
import '../stores/slidesStore.dart';
import 'resultScreen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _buttonController;
  late AnimationController _imageController;
  late Animation<double> _progressAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _imageAnimation;
  late ConfettiController _confettiController;
  int? selectedAnswer;
  bool showingExplanation = false;

  @override
  void initState() {
    super.initState();

    // O jogo já foi inicializado na tela anterior

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _imageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
    ));

    _progressController.forward();
    _imageController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _buttonController.dispose();
    _imageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _answerQuestion(int answer) async {
    if (selectedAnswer != null) return;

    final slidesStore = context.read<SlidesStore>();
    final question = slidesStore.currentQuestionObj!;
    final answerText = question.options[answer];

    setState(() {
      selectedAnswer = answer;
      showingExplanation = true;
    });

    // Register answer in SlidesStore
    await slidesStore.answerQuestion(answer);

    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    // Confetti effect for correct answer
    if (answerText == question.options[question.correctAnswer]) {
      _confettiController.play();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() async {
    final slidesStore = context.read<SlidesStore>();

    if (slidesStore.hasNextQuestion) {
      slidesStore.nextQuestion();
      setState(() {
        selectedAnswer = null;
        showingExplanation = false;
      });
      _progressController.reset();
      _imageController.reset();
      _progressController.forward();
      _imageController.forward();
    } else {
      await slidesStore.finishGame();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ResultScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SlidesStore>(
      builder: (context, slidesStore, child) {
        if (!slidesStore.gameStarted ||
            slidesStore.currentQuestionObj == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final question = slidesStore.currentQuestionObj!;
        final progress =
            (slidesStore.currentQuestion + 1) / slidesStore.totalQuestions;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: slidesStore.currentBackgroundColor != null
                        ? [
                            slidesStore.currentBackgroundColor!,
                            slidesStore.currentBackgroundColor!
                                .withOpacity(0.7),
                          ]
                        : [
                            const Color(0xFF667eea),
                            const Color(0xFF764ba2),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(progress, slidesStore),
                      const SizedBox(height: 20),
                      // Área expansível para pergunta e imagem
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildQuestion(question),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botões alinhados na parte inferior
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildOptions(question),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.5708, // 90 graus
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(double progress, SlidesStore slidesStore) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Text(
              'Pergunta ${slidesStore.currentQuestion + 1} de ${slidesStore.totalQuestions}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${slidesStore.score} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: progress * _progressAnimation.value,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestion(ISlideQuestion question) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagem da categoria
          if (question.imagePath != null) ...[
            AnimatedBuilder(
              animation: _imageAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _imageAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        question.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: _getCategoriaColor(question.category)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              _getCategoriaIcon(question.category),
                              size: 40,
                              color: _getCategoriaColor(question.category),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
              height: 1.3,
            ),
          ),
          if (showingExplanation) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedAnswer == question.correctAnswer
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedAnswer == question.correctAnswer
                      ? Colors.green
                      : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    selectedAnswer == question.correctAnswer
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: selectedAnswer == question.correctAnswer
                        ? Colors.green
                        : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: TextStyle(
                        fontSize: 12,
                        color: selectedAnswer == question.correctAnswer
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptions(ISlideQuestion question) {
    return AnimationLimiter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedAnswer == index;
            final isCorrect = index == question.correctAnswer;
            final isIncorrect = isSelected && !isCorrect;

            Color backgroundColor = Colors.white;
            Color textColor = const Color(0xFF2D3748);
            Color borderColor = Colors.grey.shade300;

            if (showingExplanation) {
              if (isCorrect) {
                backgroundColor = Colors.green.shade50;
                textColor = Colors.green.shade700;
                borderColor = Colors.green;
              } else if (isIncorrect) {
                backgroundColor = Colors.red.shade50;
                textColor = Colors.red.shade700;
                borderColor = Colors.red;
              } else {
                backgroundColor = Colors.grey.shade100;
                textColor = Colors.grey.shade600;
              }
            } else if (isSelected) {
              backgroundColor = const Color(0xFF667eea).withOpacity(0.1);
              textColor = const Color(0xFF667eea);
              borderColor = const Color(0xFF667eea);
            }

            return AnimatedBuilder(
              animation: _buttonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? _buttonAnimation.value : 1.0,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: selectedAnswer == null
                          ? () => _answerQuestion(index)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        elevation: showingExplanation ? 0 : 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index.toInt()),
                                style: TextStyle(
                                  color: backgroundColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (showingExplanation && isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (showingExplanation && isIncorrect)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getCategoriaColor(Categoria categoria) {
    switch (categoria) {
      case Categoria.geography:
        return Colors.green;
      case Categoria.science:
        return Colors.blue;
      case Categoria.literature:
        return Colors.orange;
      case Categoria.history:
        return Colors.purple;
      case Categoria.mathematics:
        return Colors.red;
      case Categoria.biology:
        return Colors.teal;
    }
  }

  IconData _getCategoriaIcon(Categoria categoria) {
    switch (categoria) {
      case Categoria.geography:
        return Icons.public;
      case Categoria.science:
        return Icons.science;
      case Categoria.literature:
        return Icons.menu_book;
      case Categoria.history:
        return Icons.history_edu;
      case Categoria.mathematics:
        return Icons.calculate;
      case Categoria.biology:
        return Icons.pets;
    }
  }
}
