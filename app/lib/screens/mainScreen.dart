import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'homeScreen.dart';
import 'trainScreen.dart';
import 'onlineScreen.dart';
import 'settingsScreen.dart';

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

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrainScreen(),
    const OnlineScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationItem> _navigationItems = [
    BottomNavigationItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Início',
      color: const Color(0xFF9C27B0),
      lottiePath: 'assets/animations/home.json',
    ),
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
      icon: Icons.settings_rounded,
      activeIcon: Icons.settings_rounded,
      label: 'Configurações',
      color: const Color(0xFF9C27B0),
      lottiePath: 'assets/animations/settings.json',
    ),
  ];

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
      if (index == 1 || index == 2) {
        _confettiController.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
