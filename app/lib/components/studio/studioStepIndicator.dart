import 'package:flutter/material.dart';
import '../../stores/studioStore.dart';

class StudioStepIndicator extends StatelessWidget {
  final StudioStore store;

  const StudioStepIndicator({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: store.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == store.currentStepIndex;
          final isCompleted = index < store.currentStepIndex;
          final isLast = index == store.steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                // Círculo do step
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? const Color(0xFF9C27B0)
                        : Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF9C27B0)
                          : Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : Icon(
                            step.icon,
                            color: isActive ? Colors.white : Colors.grey,
                            size: 20,
                          ),
                  ),
                ),
                
                // Linha conectora
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF9C27B0)
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
