import 'package:flutter/material.dart';
import '../components/genericHeader.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
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
          child: Column(
            children: [
              // Header genérico
              const GenericHeader(
                title: 'Configurações',
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
                iconColor: Colors.white,
                userIcon: Icons.settings_rounded,
              ),

              // Conteúdo principal
              Expanded(
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
                              const SizedBox(height: 16),

                              // Profile Section
                              _buildProfileCard(),

                              const SizedBox(height: 24),

                              // Settings Options
                              Expanded(
                                child: ListView(
                                  children: [
                                    _buildSettingsItem(
                                      icon: Icons.notifications_rounded,
                                      title: 'Notificações',
                                      subtitle: 'Gerenciar alertas',
                                      onTap: () =>
                                          _showNotificationsSettings(context),
                                    ),
                                    _buildSettingsItem(
                                      icon: Icons.volume_up_rounded,
                                      title: 'Som',
                                      subtitle: 'Efeitos sonoros',
                                      onTap: () => _showSoundSettings(context),
                                    ),
                                    _buildSettingsItem(
                                      icon: Icons.palette_rounded,
                                      title: 'Tema',
                                      subtitle: 'Cores e aparência',
                                      onTap: () => _showThemeSettings(context),
                                    ),
                                    _buildSettingsItem(
                                      icon: Icons.language_rounded,
                                      title: 'Idioma',
                                      subtitle: 'Português (Brasil)',
                                      onTap: () =>
                                          _showLanguageSettings(context),
                                    ),
                                    _buildSettingsItem(
                                      icon: Icons.analytics_rounded,
                                      title: 'Estatísticas',
                                      subtitle: 'Ver seu progresso',
                                      onTap: () => _showStatistics(context),
                                    ),
                                    _buildSettingsItem(
                                      icon: Icons.help_rounded,
                                      title: 'Ajuda',
                                      subtitle: 'FAQ e suporte',
                                      onTap: () => _showHelp(context),
                                    ),
                                    _buildSettingsItem(
                                      icon: Icons.info_rounded,
                                      title: 'Sobre',
                                      subtitle: 'Versão 1.0.0',
                                      onTap: () => _showAbout(context),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF9C27B0),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfilePhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foto do Perfil'),
        content: const Text('Escolha uma opção para alterar sua foto:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Câmera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Galeria'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSettings(BuildContext context) {
    // TODO: Implement notifications settings
  }

  void _showSoundSettings(BuildContext context) {
    // TODO: Implement sound settings
  }

  void _showThemeSettings(BuildContext context) {
    // TODO: Implement theme settings
  }

  void _showLanguageSettings(BuildContext context) {
    // TODO: Implement language settings
  }

  void _showStatistics(BuildContext context) {
    // TODO: Implement statistics view
  }

  void _showHelp(BuildContext context) {
    // TODO: Implement help view
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF9C27B0),
              size: 25,
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuário',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'usuario@exemplo.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz Game v1.0.0'),
            SizedBox(height: 8),
            Text('Um jogo de perguntas e respostas interativo.'),
            SizedBox(height: 8),
            Text('Desenvolvido com Flutter e Node.js'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
