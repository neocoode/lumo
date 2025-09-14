import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../stores/studioStore.dart';
import '../../../models/studioModels.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioStore>(
      builder: (context, store, child) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                const Text(
                  'Revisão Final',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Revise as informações antes de salvar seu challenge',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              const SizedBox(height: 32),

              // Conteúdo da revisão
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações básicas
                      _buildSection(
                        title: 'Informações Básicas',
                        icon: Icons.info_outline,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Título', store.title),
                            _buildInfoRow('Descrição', store.description),
                            _buildInfoRow('Categoria', _getCategoryLabel(store.category)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Perguntas
                      _buildSection(
                        title: 'Perguntas (${store.questions.length})',
                        icon: Icons.quiz_outlined,
                        child: store.questions.isEmpty
                            ? const Text(
                                'Nenhuma pergunta adicionada',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Column(
                                children: store.questions.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final question = entry.value;
                                  return _buildQuestionSummary(index + 1, question);
                                }).toList(),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Configurações do Challenge
                      _buildSection(
                        title: 'Configurações do Challenge',
                        icon: Icons.settings_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Tempo por slide', '${store.slideTime} segundos'),
                            _buildInfoRow('Tempo total', '${store.totalTime} segundos'),
                            _buildInfoRow('Dificuldade', _getDifficultyLabel(store.difficulty)),
                            _buildInfoRow('Permitir pular', store.allowSkip ? 'Sim' : 'Não'),
                            _buildInfoRow('Mostrar explicação', store.showExplanation ? 'Sim' : 'Não'),
                            _buildInfoRow('Randomizar perguntas', store.randomizeQuestions ? 'Sim' : 'Não'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Estatísticas
                      _buildSection(
                        title: 'Estatísticas',
                        icon: Icons.analytics_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Total de perguntas', '${store.questions.length}'),
                            _buildInfoRow('Categoria principal', _getCategoryLabel(store.category)),
                            _buildInfoRow('Status', store.canSaveChallenge ? 'Pronto para salvar' : 'Dados incompletos'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botões de navegação
              _buildNavigationButtons(context, store),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF9C27B0),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSummary(int number, StudioQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.question.isEmpty ? 'Pergunta sem título' : question.question,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Resposta correta: ${String.fromCharCode(65 + question.correctAnswer)}',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Explicação: ${question.explanation}',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'geography':
        return 'Geografia';
      case 'science':
        return 'Ciência';
      case 'literature':
        return 'Literatura';
      case 'history':
        return 'História';
      case 'mathematics':
        return 'Matemática';
      case 'biology':
        return 'Biologia';
      default:
        return category;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Médio';
      case 'hard':
        return 'Difícil';
      default:
        return difficulty;
    }
  }

  Widget _buildNavigationButtons(BuildContext context, StudioStore store) {
    final isFirstStep = store.currentStepIndex == 0;
    final isLastStep = store.currentStepIndex == store.steps.length - 1;
    final canProceed = store.canProceedToNextStep;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botão Voltar (apenas se não for o primeiro step)
          if (!isFirstStep) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () => store.previousStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Voltar'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Botão Próximo/Salvar
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed
                  ? () async {
                      if (isLastStep) {
                        // Salvar challenge
                        final success = await store.saveChallenge(context);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Challenge salvo com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop('saved');
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao salvar: ${store.error}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        store.nextStep();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canProceed
                    ? const Color(0xFF9C27B0)
                    : Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: store.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isLastStep ? 'Salvar' : 'Próximo'),
                        if (!isLastStep) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 18),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
