import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../stores/studioStore.dart';

class StudioNavigationButtons extends StatelessWidget {
  const StudioNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioStore>(
      builder: (context, store, child) {
        final isFirstStep = store.currentStepIndex == 0;
        final isLastStep = store.currentStepIndex == store.steps.length - 1;
        final canProceed = store.canProceedToNextStep;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Botão Cancelar
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Cancelar'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
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
      },
    );
  }
}
