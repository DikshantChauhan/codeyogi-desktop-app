import 'package:flutter/material.dart';
import 'package:desktop_app/models/sublevel_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_app/providers/user_provider.dart';

class QuizContent extends ConsumerWidget {
  final Quiz quiz;

  const QuizContent({super.key, required this.quiz});

  Widget _buildQuizImage(BuildContext context) {
    // TODO: Implement image loading
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: const Center(child: Text('Quiz image will be displayed here')),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    WidgetRef ref,
    int index,
    QuizOption option,
    int? selectedOptionIndex,
    int? correctOptionIndex,
  ) {
    final isSelected = selectedOptionIndex == index;
    final isCorrect = correctOptionIndex == index;

    // Determine button state and color
    Color buttonColor;
    bool isDisabled = false;

    if (selectedOptionIndex != null) {
      // After selection
      if (isSelected) {
        // Selected option
        buttonColor = isCorrect ? Colors.green : Colors.red;
      } else if (isCorrect) {
        // Correct option (when wrong answer selected)
        buttonColor = Colors.green;
      } else {
        // Other options
        buttonColor = Colors.grey;
      }
      isDisabled = true;
    } else {
      // Before selection
      buttonColor = Theme.of(context).colorScheme.primary;
      isDisabled = false;
    }

    return ElevatedButton(
      onPressed:
          isDisabled
              ? null
              : () async {
                await ref
                    .read(userProvider.notifier)
                    .setQuizData(quiz.id, index);
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: buttonColor,
        disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(option.value, style: const TextStyle(fontSize: 16)),
          ),
          if (isSelected && option.reason != null)
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizData = ref.watch(userProvider).quizData;
    final selectedOptionIndex = quizData?[quiz.id];
    final correctOptionIndex = quiz.options.indexWhere(
      (option) => option.correct == true,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(quiz.title, style: Theme.of(context).textTheme.headlineMedium),
          if (quiz.image != null) ...[
            const SizedBox(height: 16),
            _buildQuizImage(context),
          ],
          const SizedBox(height: 24),
          ...quiz.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildOptionButton(
                context,
                ref,
                index,
                option,
                selectedOptionIndex,
                correctOptionIndex,
              ),
            );
          }),
        ],
      ),
    );
  }
}
