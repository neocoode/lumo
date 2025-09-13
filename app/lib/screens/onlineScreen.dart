import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../stores/challengesStore.dart';
import 'gameScreen.dart';

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({super.key});

  @override
  State<OnlineScreen> createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
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
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.wifi_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        'Modo Online',
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
                                        'Jogue com seus amigos',
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

                        // Online indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ONLINE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Online challenges
                        Expanded(
                          child: Consumer<ChallengesStore>(
                            builder: (context, challengesStore, child) {
                              return ListView(
                                children: [
                                  _buildOnlineChallenge(
                                    title: 'Desafio Diário',
                                    subtitle: '5 perguntas sobre geografia',
                                    difficulty: 'Fácil',
                                    timeLeft: '2h 30min',
                                    participants: 1247,
                                    color: const Color(0xFF4CAF50),
                                    onTap: () => _startOnlineChallenge(
                                        context, challengesStore, 'daily'),
                                  ),
                                  _buildOnlineChallenge(
                                    title: 'Quiz da Semana',
                                    subtitle: '10 perguntas mistas',
                                    difficulty: 'Médio',
                                    timeLeft: '5d 12h',
                                    participants: 3421,
                                    color: const Color(0xFF2196F3),
                                    onTap: () => _startOnlineChallenge(
                                        context, challengesStore, 'weekly'),
                                  ),
                                  _buildOnlineChallenge(
                                    title: 'Desafio Especial',
                                    subtitle: 'História do Brasil',
                                    difficulty: 'Difícil',
                                    timeLeft: '1d 8h',
                                    participants: 892,
                                    color: const Color(0xFFFF9800),
                                    onTap: () => _startOnlineChallenge(
                                        context, challengesStore, 'special'),
                                  ),
                                  _buildOnlineChallenge(
                                    title: 'Quiz Relâmpago',
                                    subtitle: '3 perguntas em 30 segundos',
                                    difficulty: 'Extremo',
                                    timeLeft: '45min',
                                    participants: 567,
                                    color: const Color(0xFFE91E63),
                                    onTap: () => _startOnlineChallenge(
                                        context, challengesStore, 'lightning'),
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

  Widget _buildOnlineChallenge({
    required String title,
    required String subtitle,
    required String difficulty,
    required String timeLeft,
    required int participants,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Restam: $timeLeft',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.people_rounded,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$participants participantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startOnlineChallenge(BuildContext context,
      ChallengesStore challengesStore, String challengeType) async {
    // Start online challenge
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
