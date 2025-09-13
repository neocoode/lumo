import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../stores/studioStore.dart';
import 'steps/basicConfigStep.dart';
import 'steps/questionsStep.dart';
import 'steps/challengeConfigStep.dart';
import 'steps/reviewStep.dart';

class StudioStepContent extends StatelessWidget {
  const StudioStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioStore>(
      builder: (context, store, child) {
        switch (store.currentStepIndex) {
          case 0:
            return const BasicConfigStep();
          case 1:
            return const QuestionsStep();
          case 2:
            return const ChallengeConfigStep();
          case 3:
            return const ReviewStep();
          default:
            return const Center(
              child: Text('Step não encontrado'),
            );
        }
      },
    );
  }
}
