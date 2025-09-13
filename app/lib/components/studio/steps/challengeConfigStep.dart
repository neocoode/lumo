import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../stores/studioStore.dart';

class ChallengeConfigStep extends StatefulWidget {
  const ChallengeConfigStep({super.key});

  @override
  State<ChallengeConfigStep> createState() => _ChallengeConfigStepState();
}

class _ChallengeConfigStepState extends State<ChallengeConfigStep> {
  final _slideTimeController = TextEditingController();
  final _totalTimeController = TextEditingController();
  bool _allowSkip = true;
  bool _showExplanation = true;
  bool _randomizeQuestions = false;
  String _difficulty = 'medium';

  final List<Map<String, String>> _difficulties = [
    {'value': 'easy', 'label': 'Fácil'},
    {'value': 'medium', 'label': 'Médio'},
    {'value': 'hard', 'label': 'Difícil'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final store = Provider.of<StudioStore>(context, listen: false);
    _slideTimeController.text = store.slideTime.toString();
    _totalTimeController.text = store.totalTime.toString();
    _allowSkip = store.allowSkip;
    _showExplanation = store.showExplanation;
    _randomizeQuestions = store.randomizeQuestions;
    _difficulty = store.difficulty;
  }

  @override
  void dispose() {
    _slideTimeController.dispose();
    _totalTimeController.dispose();
    super.dispose();
  }

  void _updateStore() {
    final store = Provider.of<StudioStore>(context, listen: false);
    store.updateChallengeConfig(
      slideTime: int.tryParse(_slideTimeController.text) ?? 30,
      totalTime: int.tryParse(_totalTimeController.text) ?? 300,
      allowSkip: _allowSkip,
      showExplanation: _showExplanation,
      randomizeQuestions: _randomizeQuestions,
      difficulty: _difficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioStore>(
      builder: (context, store, child) {
        // Atualizar controllers quando o store mudar
        if (store.slideTime.toString() != _slideTimeController.text) {
          _slideTimeController.text = store.slideTime.toString();
        }
        if (store.totalTime.toString() != _totalTimeController.text) {
          _totalTimeController.text = store.totalTime.toString();
        }
        if (store.allowSkip != _allowSkip) {
          _allowSkip = store.allowSkip;
        }
        if (store.showExplanation != _showExplanation) {
          _showExplanation = store.showExplanation;
        }
        if (store.randomizeQuestions != _randomizeQuestions) {
          _randomizeQuestions = store.randomizeQuestions;
        }
        if (store.difficulty != _difficulty) {
          _difficulty = store.difficulty;
        }

        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da seção
                  const Text(
                    'Configurações do Desafio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure o tempo e comportamento do seu challenge',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                const SizedBox(height: 32),

                // Tempo por slide
                _buildInputField(
                  label: 'Tempo por Slide (segundos)',
                  controller: _slideTimeController,
                  hintText: 'Ex: 30',
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateStore(),
                ),
                const SizedBox(height: 24),

                // Tempo total
                _buildInputField(
                  label: 'Tempo Total (segundos)',
                  controller: _totalTimeController,
                  hintText: 'Ex: 300',
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateStore(),
                ),
                const SizedBox(height: 24),

                // Dificuldade
                _buildDropdownField(
                  label: 'Dificuldade',
                  value: _difficulty,
                  items: _difficulties,
                  onChanged: (value) {
                    setState(() {
                      _difficulty = value!;
                    });
                    _updateStore();
                  },
                ),
                const SizedBox(height: 24),

                // Opções de comportamento
                const Text(
                  'Opções de Comportamento',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Permitir pular
                _buildSwitchField(
                  label: 'Permitir Pular Perguntas',
                  subtitle: 'Permite que o usuário pule perguntas sem responder',
                  value: _allowSkip,
                  onChanged: (value) {
                    setState(() {
                      _allowSkip = value;
                    });
                    _updateStore();
                  },
                ),
                const SizedBox(height: 16),

                // Mostrar explicação
                _buildSwitchField(
                  label: 'Mostrar Explicação',
                  subtitle: 'Exibe a explicação após cada pergunta',
                  value: _showExplanation,
                  onChanged: (value) {
                    setState(() {
                      _showExplanation = value;
                    });
                    _updateStore();
                  },
                ),
                const SizedBox(height: 16),

                // Randomizar perguntas
                _buildSwitchField(
                  label: 'Randomizar Perguntas',
                  subtitle: 'Apresenta as perguntas em ordem aleatória',
                  value: _randomizeQuestions,
                  onChanged: (value) {
                    setState(() {
                      _randomizeQuestions = value;
                    });
                    _updateStore();
                  },
                ),
                const SizedBox(height: 20),
                // Botões de navegação
                _buildNavigationButtons(context, store),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF9C27B0),
            activeTrackColor: Colors.purple.withOpacity(0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
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
