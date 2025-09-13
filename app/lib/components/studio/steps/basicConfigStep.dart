import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../stores/studioStore.dart';

class BasicConfigStep extends StatefulWidget {
  const BasicConfigStep({super.key});

  @override
  State<BasicConfigStep> createState() => _BasicConfigStepState();
}

class _BasicConfigStepState extends State<BasicConfigStep> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'geography';

  final List<Map<String, String>> _categories = [
    {'value': 'geography', 'label': 'Geografia'},
    {'value': 'science', 'label': 'Ciência'},
    {'value': 'literature', 'label': 'Literatura'},
    {'value': 'history', 'label': 'História'},
    {'value': 'mathematics', 'label': 'Matemática'},
    {'value': 'biology', 'label': 'Biologia'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
    
    // Listener para quando o store for atualizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = Provider.of<StudioStore>(context, listen: false);
      if (store.title.isNotEmpty || store.description.isNotEmpty) {
        _loadCurrentData();
      }
    });
  }

  void _loadCurrentData() {
    final store = Provider.of<StudioStore>(context, listen: false);
    _titleController.text = store.title;
    _descriptionController.text = store.description;
    _selectedCategory = store.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateStore() {
    final store = Provider.of<StudioStore>(context, listen: false);
    store.updateBasicConfig(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioStore>(
      builder: (context, store, child) {
        // Atualizar controllers quando o store mudar
        if (store.title != _titleController.text) {
          _titleController.text = store.title;
        }
        if (store.description != _descriptionController.text) {
          _descriptionController.text = store.description;
        }
        if (store.category != _selectedCategory) {
          _selectedCategory = store.category;
        }
        
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da seção
                const Text(
                  'Configurações Básicas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Defina as informações básicas do seu challenge',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              const SizedBox(height: 32),

              // Campo Título
              _buildInputField(
                label: 'Título do Challenge',
                controller: _titleController,
                hintText: 'Ex: Quiz de Geografia do Brasil',
                maxLines: 1,
                onChanged: (value) => _updateStore(),
              ),
              const SizedBox(height: 24),

              // Campo Descrição
              _buildInputField(
                label: 'Descrição',
                controller: _descriptionController,
                hintText: 'Descreva o que os participantes vão aprender...',
                maxLines: 3,
                onChanged: (value) => _updateStore(),
              ),
              const SizedBox(height: 24),

              // Seletor de Categoria
              const Text(
                'Categoria',
                style: TextStyle(
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
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['value'],
                      child: Text(category['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _updateStore();
                    }
                  },
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
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