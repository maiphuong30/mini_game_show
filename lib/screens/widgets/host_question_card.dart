import 'package:flutter/material.dart';

class HostQuestionCard extends StatelessWidget {
  final String question;
  final List<String> answers;
  final int? selectedAnswer;
  final int? correctAnswer;
  final bool showAnswer;
  final ValueChanged<int> onSelectAnswer;

  const HostQuestionCard({
    super.key,
    required this.question,
    required this.answers,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.showAnswer,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['A', 'B', 'C', 'D'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (answers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...answers.asMap().entries.map((entry) {
                final index = entry.key;
                final isSelected = selectedAnswer == index;
                final isCorrect =
                    showAnswer && correctAnswer == index;
                final isWrongSelected =
                    showAnswer && isSelected && !isCorrect;

                final Color? cardColor = isCorrect
                    ? Colors.green.withValues(alpha: 0.15)
                    : isWrongSelected
                    ? Colors.red.withValues(alpha: 0.15)
                    : isSelected
                    ? Colors.blue.withValues(alpha: 0.12)
                    : null;

                return Card(
                  color: cardColor,
                  child: ListTile(
                    onTap: () => onSelectAnswer(index),
                    leading: CircleAvatar(
                      child: Text(
                        index < labels.length
                            ? labels[index]
                            : '${index + 1}',
                      ),
                    ),
                    title: Text(entry.value),
                    trailing: isCorrect
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : isSelected
                        ? const Icon(
                      Icons.radio_button_checked,
                      color: Colors.blue,
                    )
                        : null,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}