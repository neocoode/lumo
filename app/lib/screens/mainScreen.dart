import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'trainScreen.dart';
import 'onlineScreen.dart';
import 'studioScreen.dart';
import 'menuScreen.dart';
import '../stores/sessionStore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  // Screens disponíveis
  final List<Widget> _allScreens = [
    const TrainScreen(),
    const OnlineScreen(),
    const StudioScreen(),
    const MenuScreen(),
  ];

  // Itens de navegação disponíveis
  final List<BottomNavigationItem> _allNavigationItems = [
    BottomNavigationItem(
      icon: Icons.fitness_center_rounded,
      activeIcon: Icons.fitness_center_rounded,
      label: 'Treinar',
      color: const Color(0xFF4CAF50),
      lottiePath: 'assets/animations/train.json',
    ),
    BottomNavigationItem(
      icon: Icons.wifi_rounded,
      activeIcon: Icons.wifi_rounded,
      label: 'Online',
      color: const Color(0xFFE91E63),
      lottiePath: 'assets/animations/live.json',
    ),
    BottomNavigationItem(
      icon: Icons.movie_creation_rounded,
      activeIcon: Icons.movie_creation_rounded,
      label: 'Studio',
      color: const Color(0xFF9C27B0),
      lottiePath: 'assets/animations/studio.json',
    ),
    BottomNavigationItem(
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      label: 'Menu',
      color: const Color(0xFF9C27B0),
      lottiePath: 'assets/animations/settings.json',
    ),
  ];

  // Getters para screens e itens baseados no status de login
  List<Widget> get _screens {
    final sessionStore = context.read<SessionStore>();
    final isLoggedIn = sessionStore.isAuthenticated();
    
    if (isLoggedIn) {
      return _allScreens; // Todos os screens quando logado
    } else {
      return [_allScreens[0], _allScreens[3]]; // Apenas Treinar e Menu quando não logado
    }
  }

  List<BottomNavigationItem> get _navigationItems {
    final sessionStore = context.read<SessionStore>();
    final isLoggedIn = sessionStore.isAuthenticated();
    
    if (isLoggedIn) {
      return _allNavigationItems; // Todos os itens quando logado
    } else {
      return [_allNavigationItems[0], _allNavigationItems[3]]; // Apenas Treinar e Menu quando não logado
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Confetti effect for certain tabs
      if (index == 0 || index == 1) {
        _confettiController.play();
      }
    }
  }

  // Método para ajustar o índice quando o status de login muda
  void _adjustIndexForLoginStatus(SessionStore sessionStore) {
    final isLoggedIn = sessionStore.isAuthenticated();
    
    if (!isLoggedIn && _currentIndex > 1) {
      // Se não está logado e está em Online (1) ou Studio (2), voltar para Treinar (0)
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionStore>(
      builder: (context, sessionStore, child) {
        // Ajustar índice se necessário
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _adjustIndexForLoginStatus(sessionStore);
        });

        return Scaffold(
          body: Stack(
            children: [
              // Main content
              _screens[_currentIndex],

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // Downward
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [
                Color(0xFF667eea),
                Color(0xFF4CAF50),
                Color(0xFFE91E63),
                Color(0xFF9C27B0),
                Color(0xFFFF9800),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF7B1FA2).withOpacity(0.7),
                const Color(0xFF4A148C).withOpacity(0.8),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == _currentIndex;

                return GestureDetector(
                  onTap: () => _onTabTapped(index),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      final scale = isSelected ? _scaleAnimation.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Icon with gradient effect
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            const Color(0xFF9C27B0),
                                            const Color(0xFF7B1FA2),
                                          ],
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF9C27B0)
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  size: isSelected ? 24 : 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Label with animation
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  fontSize: isSelected ? 10 : 9,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                                child: Text(item.label),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
        );
      },
    );
  }
}

class BottomNavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final String lottiePath;

  const BottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.lottiePath,
  });
}
