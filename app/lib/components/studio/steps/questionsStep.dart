import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../stores/studioStore.dart';
import 'questionEditor.dart';

class QuestionsStep extends StatelessWidget {
  const QuestionsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioStore>(
      builder: (context, store, child) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Cabeçalho
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perguntas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Adicione e configure as perguntas do challenge',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showQuestionEditor(context, store, null, null),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Adicionar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de perguntas
            Expanded(
              child: store.questions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: store.questions.length + 1, // +1 para os botões
                      itemBuilder: (context, index) {
                        if (index == store.questions.length) {
                          // Último item: botões de navegação
                          return _buildNavigationButtons(context, store);
                        }
                        return _buildQuestionCard(
                          context,
                          store,
                          index,
                          store.questions[index],
                        );
                      },
                    ),
            ),
          ],
        ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma pergunta adicionada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Adicionar" para criar sua primeira pergunta',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    StudioStore store,
    int index,
    StudioQuestion question,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Cabeçalho da pergunta
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question.isEmpty
                        ? 'Pergunta ${index + 1}'
                        : question.question,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                  ),
                  color: Colors.white,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('Editar', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showQuestionEditor(context, store, index, question);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, store, index);
                    }
                  },
                ),
              ],
            ),
          ),

          // Conteúdo da pergunta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Opções
                const Text(
                  'Opções:',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...question.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final option = entry.value;
                  final isCorrect = optionIndex == question.correctAnswer;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.3)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isCorrect ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + optionIndex), // A, B, C, D
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
                            option.isEmpty ? 'Opção ${optionIndex + 1}' : option,
                            style: TextStyle(
                              color: isCorrect ? Colors.green.shade700 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isCorrect)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                      ],
                    ),
                  );
                }).toList(),

                // Botão editar
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showQuestionEditor(context, store, index, question),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar Pergunta'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9C27B0),
                      side: const BorderSide(color: Color(0xFF9C27B0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionEditor(
    BuildContext context,
    StudioStore store,
    int? index,
    StudioQuestion? question,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionEditor(
        question: question ?? StudioQuestion(
          question: '',
          options: ['', '', '', ''],
          correctAnswer: 0,
          explanation: '',
          category: 'geography',
        ),
        onSave: (newQuestion) {
          if (index != null) {
            store.updateQuestion(index, newQuestion);
          } else {
            store.addQuestion();
            store.updateQuestion(store.questions.length - 1, newQuestion);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StudioStore store, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Excluir Pergunta',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esta pergunta?',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              store.removeQuestion(index);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
                        final success = await store.saveChallenge();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Challenge salvo com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
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