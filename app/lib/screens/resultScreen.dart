import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../components/resultHeader.dart';
import '../components/resultScore.dart';
import '../components/resultButtons.dart';
import '../components/resultConfetti.dart';
import '../stores/challengesStore.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _buttonController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _buttonAnimation;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _confetti = ConfettiController(duration: const Duration(seconds: 2));

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0, // Será calculado dinamicamente no build
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _scoreController.forward();

    // Confetti será controlado no build method
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final challengesStore = context.read<ChallengesStore>();
        if (challengesStore.shouldShowConfetti) {
          _confetti.play();
        }
      }
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _buttonController.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengesStore>(
      builder: (context, challengesStore, child) {
        final corResultado = challengesStore.getResultColor();
        final mensagem = challengesStore.getResultMessage();
        final icone = challengesStore.getResultIcon();
        final shouldShowConfetti = challengesStore.shouldShowConfetti;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                      Color(0xFFf093fb),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResultHeader(
                          message: mensagem,
                          icon: icone,
                        ),
                        const SizedBox(height: 40),
                        ResultScore(
                          score: challengesStore.score,
                          totalQuestions: challengesStore.totalQuestions,
                          scoreAnimation: _scoreAnimation,
                          resultColor: corResultado,
                        ),
                        const SizedBox(height: 40),
                        ResultButtons(
                          buttonAnimation: _buttonAnimation,
                          buttonController: _buttonController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ResultConfetti(
                confettiController: _confetti,
                shouldShow: shouldShowConfetti,
              ),
            ],
          ),
        );
      },
    );
  }
}
