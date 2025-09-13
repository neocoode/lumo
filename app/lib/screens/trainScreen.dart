import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../stores/challengesStore.dart';
import 'gameScreen.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9C27B0),
              Color(0xFF8E24AA),
              Color(0xFF7B1FA2),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        'Modo Treino',
                                        textStyle: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        speed:
                                            const Duration(milliseconds: 100),
                                      ),
                                    ],
                                    totalRepeatCount: 1,
                                  ),
                                  const SizedBox(height: 20),
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      FadeAnimatedText(
                                        'Pratique sem pressão',
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 2000),
                                      ),
                                    ],
                                    totalRepeatCount: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Training modes
                        Expanded(
                          child: Consumer<ChallengesStore>(
                            builder: (context, challengesStore, child) {
                              return GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.1,
                                children: [
                                  _buildTrainingCard(
                                    icon: Icons.quiz_rounded,
                                    title: 'Quiz Rápido',
                                    subtitle: '5 perguntas',
                                    color: const Color(0xFF2196F3),
                                    onTap: () => _startQuickQuiz(
                                        context, challengesStore),
                                  ),
                                  _buildTrainingCard(
                                    icon: Icons.category_rounded,
                                    title: 'Por Categoria',
                                    subtitle: 'Geografia',
                                    color: const Color(0xFF9C27B0),
                                    onTap: () => _startCategoryTraining(
                                        context, challengesStore, 'geography'),
                                  ),
                                  _buildTrainingCard(
                                    icon: Icons.science_rounded,
                                    title: 'Ciências',
                                    subtitle: 'Física e Química',
                                    color: const Color(0xFFFF9800),
                                    onTap: () => _startCategoryTraining(
                                        context, challengesStore, 'science'),
                                  ),
                                  _buildTrainingCard(
                                    icon: Icons.menu_book_rounded,
                                    title: 'Literatura',
                                    subtitle: 'Livros e autores',
                                    color: const Color(0xFFE91E63),
                                    onTap: () => _startCategoryTraining(
                                        context, challengesStore, 'literature'),
                                  ),
                                  _buildTrainingCard(
                                    icon: Icons.history_rounded,
                                    title: 'História',
                                    subtitle: 'Brasil e mundo',
                                    color: const Color(0xFF795548),
                                    onTap: () => _startCategoryTraining(
                                        context, challengesStore, 'history'),
                                  ),
                                  _buildTrainingCard(
                                    icon: Icons.psychology_rounded,
                                    title: 'Aleatório',
                                    subtitle: 'Todas as categorias',
                                    color: const Color(0xFF607D8B),
                                    onTap: () => _startRandomTraining(
                                        context, challengesStore),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuickQuiz(
      BuildContext context, ChallengesStore challengesStore) async {
    // Start a quick 5-question quiz
    await challengesStore.startGame();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      );
    }
  }

  void _startCategoryTraining(BuildContext context,
      ChallengesStore challengesStore, String category) async {
    // Start training for specific category
    await challengesStore.startGame();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      );
    }
  }

  void _startRandomTraining(
      BuildContext context, ChallengesStore challengesStore) async {
    // Start random training
    await challengesStore.startGame();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      );
    }
  }
}
