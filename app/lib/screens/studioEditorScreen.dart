import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/studioStore.dart';
import '../components/genericHeader.dart';
import '../components/studio/studioStepIndicator.dart';
import '../components/studio/studioStepContent.dart';
import '../components/studio/studioNavigationButtons.dart';
import '../services/challengesListService.dart';

class StudioEditorScreen extends StatefulWidget {
  final ChallengeItem? challengeToEdit;

  const StudioEditorScreen({
    super.key,
    this.challengeToEdit,
  });

  @override
  State<StudioEditorScreen> createState() => _StudioEditorScreenState();
}

class _StudioEditorScreenState extends State<StudioEditorScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StudioStore(),
      child: Consumer<StudioStore>(
        builder: (context, store, child) {
          // Carregar challenge para edição se fornecido, ou inicializar para criação
          if (widget.challengeToEdit != null && store.currentChallenge == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              store.loadChallengeForEdit(widget.challengeToEdit!);
            });
          } else if (widget.challengeToEdit == null && store.currentChallenge != null) {
            // Se não há challenge para editar, inicializar para criação
            WidgetsBinding.instance.addPostFrameCallback((_) {
              store.startNewChallenge();
            });
          }

          // Sincronizar PageController com o step atual
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients && _pageController.page?.round() != store.currentStepIndex) {
              _pageController.animateToPage(
                store.currentStepIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Indicador de steps
                  Consumer<StudioStore>(
                    builder: (context, store, child) => StudioStepIndicator(store: store),
                  ),

                  // Conteúdo dos steps com swipe
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        // Só permite mudança se o step anterior for válido
                        if (index > store.currentStepIndex) {
                          if (store.canProceedToNextStep) {
                            store.goToStep(index);
                          } else {
                            // Volta para o step anterior se não pode prosseguir
                            _pageController.animateToPage(
                              store.currentStepIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        } else {
                          // Permite voltar sempre
                          store.goToStep(index);
                        }
                      },
                      children: const [
                        // Step 1: Configurações Básicas
                        StudioStepContent(),
                        // Step 2: Perguntas
                        StudioStepContent(),
                        // Step 3: Revisão
                        StudioStepContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
