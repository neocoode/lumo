import 'package:flutter/material.dart';
import '../../../stores/studioStore.dart';

class QuestionEditor extends StatefulWidget {
  final StudioQuestion? question;
  final Function(StudioQuestion) onSave;

  const QuestionEditor({
    super.key,
    this.question,
    required this.onSave,
  });

  @override
  State<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _explanationController;
  late String _selectedCategory;
  int _correctAnswer = 0;
  String? _selectedImage;
  late ScrollController _scrollController;
  bool _showActionButtons = true;

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
    _scrollController = ScrollController();
    _initializeControllers();
  }

  void _initializeControllers() {
    _questionController = TextEditingController(text: widget.question?.question ?? '');
    _explanationController = TextEditingController(text: widget.question?.explanation ?? '');
    _selectedCategory = widget.question?.category ?? 'geography';
    _correctAnswer = widget.question?.correctAnswer ?? 0;
    _selectedImage = widget.question?.imagePath;

    // Inicializar com 2 opções se for nova pergunta, senão usar as existentes
    final initialOptions = widget.question?.options ?? ['', ''];
    _optionControllers = initialOptions.map((option) => TextEditingController(text: option)).toList();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    _scrollController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
        // Ajustar resposta correta se necessário
        if (_correctAnswer >= index) {
          _correctAnswer = _correctAnswer > 0 ? _correctAnswer - 1 : 0;
        }
      });
    }
  }

  void _saveQuestion() {
    final options = _optionControllers.map((controller) => controller.text.trim()).toList();
    
    // Validar se há pelo menos 2 opções preenchidas
    final validOptions = options.where((option) => option.isNotEmpty).toList();
    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos 2 opções válidas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar se a pergunta não está vazia
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite a pergunta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final question = StudioQuestion(
      question: _questionController.text.trim(),
      options: options,
      correctAnswer: _correctAnswer,
      explanation: _explanationController.text.trim(),
      category: _selectedCategory,
      imagePath: _selectedImage,
    );

    widget.onSave(question);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Editar Pergunta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo Pergunta
                  _buildInputField(
                    label: 'Pergunta',
                    controller: _questionController,
                    hintText: 'Digite sua pergunta aqui...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Campo Imagem
                  _buildImageField(),
                  const SizedBox(height: 24),

                  // Opções de Resposta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Opções de Resposta',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_optionControllers.length < 6)
                        IconButton(
                          onPressed: _addOption,
                          icon: const Icon(Icons.add_circle, color: Color(0xFF9C27B0)),
                          tooltip: 'Adicionar opção',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de opções
                  ..._optionControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    final isSelected = index == _correctAnswer;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Botão de seleção
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _correctAnswer = index;
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.green : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.green : const Color(0xFF9C27B0),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Campo de texto da opção
                          Expanded(
                            child: _buildInputField(
                              label: 'Opção ${String.fromCharCode(65 + index)}',
                              controller: controller,
                              hintText: 'Digite a opção ${String.fromCharCode(65 + index)}...',
                              maxLines: 1,
                            ),
                          ),

                          // Botão remover (apenas se tiver mais de 2 opções)
                          if (_optionControllers.length > 2)
                            IconButton(
                              onPressed: () => _removeOption(index),
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              tooltip: 'Remover opção',
                            ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Campo Explicação
                  _buildInputField(
                    label: 'Explicação',
                    controller: _explanationController,
                    hintText: 'Explique por que esta é a resposta correta...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Campo Categoria
                  _buildCategoryField(),
                  const SizedBox(height: 24),

                  // Botão de ação
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Salvar Pergunta'),
                    ),
                  ),
                  const SizedBox(height: 20), // Espaço extra no final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
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
              color: Color(0xFF333333),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagem (Opcional)',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildImagePlaceholder(),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            color: Colors.grey.shade400,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Toque para adicionar imagem',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Color(0xFF333333),
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
              }
            },
          ),
        ),
      ],
    );
  }
}