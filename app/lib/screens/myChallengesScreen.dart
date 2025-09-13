import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/challengesListService.dart';
import '../models/apiModels.dart';
import '../components/genericHeader.dart';
import 'gameScreen.dart';
import 'studioEditorScreen.dart';

class MyChallengesScreen extends StatefulWidget {
  const MyChallengesScreen({super.key});

  @override
  State<MyChallengesScreen> createState() => _MyChallengesScreenState();
}

class _MyChallengesScreenState extends State<MyChallengesScreen> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _listController;
  late Animation<double> _iconAnimation;
  late Animation<double> _listAnimation;
  
  final ChallengesListService _challengesListService = ChallengesListService();
  ChallengesListResponse? _challengesData;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutBack,
    ));

    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _listController.forward();
    });

    // Carregar challenges ao inicializar
    _loadChallenges();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _listController.dispose();
    _challengesListService.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final challengesData = await _challengesListService.getChallengesList();
      setState(() {
        _challengesData = challengesData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar challenges: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9C27B0).withOpacity(0.8),
              const Color(0xFF7B1FA2).withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildChallengesList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewChallenge,
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Desafio'),
        elevation: 8,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Header genérico usando componente separado
        const GenericHeader(
          title: 'Challenges Disponíveis',
        ),
        
        // Ícone principal animado
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: AnimatedBuilder(
            animation: _iconAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconAnimation.value,
                child: Transform.rotate(
                  angle: _iconAnimation.value * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Textos animados
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Challenges Disponíveis',
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              const SizedBox(height: 10),
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Explore e jogue os slides disponíveis',
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadChallenges(),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_challengesData == null || _challengesData!.challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
                Text(
                  'Nenhum quiz encontrado',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifique sua conexão com a API',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _listAnimation.value,
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _challengesData!.challenges.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildChallengeCard(_challengesData!.challenges[index], index),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChallengeCard(ChallengeItem challenge, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  Icons.quiz_outlined,
                  '${challenge.questionCount} pergunta',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.category_outlined,
                  _getCategoryName(challenge.category),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.access_time,
                  _formatDate(challenge.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  Icons.person_outline,
                  challenge.author,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.trending_up,
                  challenge.difficulty,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Editar',
                    Icons.edit_rounded,
                    Colors.blue,
                    () => _editChallenge(challenge),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Excluir',
                    Icons.delete_rounded,
                    Colors.red,
                    () => _deleteChallenge(challenge),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Preview',
                    Icons.visibility_rounded,
                    Colors.green,
                    () => _previewChallenge(challenge),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8), // Aumentado de 0.2 para 0.8
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.9), // Aumentado de 0.5 para 0.9
            width: 1.5, // Aumentado de 1 para 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18, // Aumentado de 16 para 18
              color: Colors.white, // Mudado para branco para melhor contraste
            ),
            const SizedBox(width: 6), // Aumentado de 4 para 6
            Text(
              text,
              style: const TextStyle(
                fontSize: 14, // Aumentado de 12 para 14
                fontWeight: FontWeight.bold, // Mudado de w600 para bold
                color: Colors.white, // Mudado para branco para melhor contraste
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(Categoria category) {
    switch (category) {
      case Categoria.geography:
        return 'Geografia';
      case Categoria.science:
        return 'Ciência';
      case Categoria.literature:
        return 'Literatura';
      case Categoria.history:
        return 'História';
      case Categoria.mathematics:
        return 'Matemática';
      case Categoria.biology:
        return 'Biologia';
      default:
        return 'Outros';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _editChallenge(ChallengeItem challenge) async {
    // Navegar para tela de edição do Studio
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudioEditorScreen(
          challengeToEdit: challenge,
        ),
      ),
    );
    
    // Se retornou da tela de edição, recarregar a lista
    if (result == true || result == 'saved') {
      _loadChallenges();
    }
  }

  Future<void> _createNewChallenge() async {
    // Navegar para tela de criação do Studio
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudioEditorScreen(),
      ),
    );
    
    // Se retornou da tela de criação, recarregar a lista
    if (result == true || result == 'saved') {
      _loadChallenges();
    }
  }

  void _deleteChallenge(ChallengeItem challenge) {
    // Mostrar confirmação de exclusão
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Confirmar Exclusão',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text('Tem certeza que deseja excluir "${challenge.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteChallenge(challenge);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteChallenge(ChallengeItem challenge) {
    // Implementar lógica de exclusão
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${challenge.title} excluído com sucesso!'),
        backgroundColor: Colors.red,
      ),
    );
    // TODO: Implementar exclusão real e atualizar lista
  }

  void _previewChallenge(ChallengeItem challenge) {
    // Navegar para preview do challenge
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
    // TODO: Implementar modo preview no GameScreen
  }
}
