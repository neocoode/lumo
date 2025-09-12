import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ResultConfetti extends StatelessWidget {
  final ConfettiController confettiController;
  final bool shouldShow;

  const ResultConfetti({
    super.key,
    required this.confettiController,
    required this.shouldShow,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: confettiController,
        blastDirection: 1.5708, // 90 graus
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
        ],
      ),
    );
  }
}
