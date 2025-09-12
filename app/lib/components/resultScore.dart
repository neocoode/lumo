import 'package:flutter/material.dart';

class ResultScore extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final Animation<double> scoreAnimation;
  final Color resultColor;

  const ResultScore({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.scoreAnimation,
    required this.resultColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentual = (score / totalQuestions) * 100;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
            AnimatedBuilder(
            animation: scoreAnimation,
            builder: (context, child) {
              final progressValue = (score / totalQuestions) * scoreAnimation.value;
              return SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            '$score/$totalQuestions',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentual.toStringAsFixed(0)}% de acerto',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
