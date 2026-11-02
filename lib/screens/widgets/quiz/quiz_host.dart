import 'package:flutter/material.dart';

import '../../../models/game_state.dart';
import '../host_bonus_card.dart';
import '../host_question_card.dart';

class QuizHost extends StatelessWidget {
  final GameState state;
  final int questionCount;

  final ValueChanged<int> onSelectTeam;
  final ValueChanged<int> onSelectAnswer;
  final VoidCallback onRevealAnswer;
  final ValueChanged<bool> onResolveBonus;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReturnToLobby;

  const QuizHost({
    super.key,
    required this.state,
    required this.questionCount,
    required this.onSelectTeam,
    required this.onSelectAnswer,
    required this.onRevealAnswer,
    required this.onResolveBonus,
    required this.onPrevious,
    required this.onNext,
    required this.onReturnToLobby,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = state.correctAnswer != null &&
        state.selectedAnswer == state.correctAnswer;

    final selectedTeamName = state.selectedTeam >= 0 &&
        state.selectedTeam < state.teams.length
        ? state.teams[state.selectedTeam]
        : 'Đội được chọn';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostQuestionCard(
          question: state.question,
          answers: state.answers,
          selectedAnswer: state.selectedAnswer,
          correctAnswer: state.correctAnswer,
          showAnswer: state.showAnswer,
          onSelectAnswer: onSelectAnswer,
        ),

        const SizedBox(height: 12),

        const Text(
          'Đội trả lời',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.teams.asMap().entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.value),
              selected: state.selectedTeam == entry.key,
              onSelected: state.showAnswer || state.scoreAwarded
                  ? null
                  : (_) => onSelectTeam(entry.key),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        if (state.selectedAnswer != null &&
            state.selectedAnswer! >= 0 &&
            state.selectedAnswer! < state.answers.length)
          Text('Đã chọn: ${state.answers[state.selectedAnswer!]}'),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.showAnswer ? null : onRevealAnswer,
            icon: const Icon(Icons.campaign),
            label: Text(
              state.showAnswer
                  ? 'Đã công bố đáp án'
                  : 'Công bố đáp án và tính điểm',
            ),
          ),
        ),

        if (state.showAnswer) ...[
          const SizedBox(height: 8),
          Text(
            isCorrect
                ? '$selectedTeamName trả lời đúng!'
                : '$selectedTeamName trả lời chưa đúng.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ],

        if (state.bonusUnlocked) ...[
          const SizedBox(height: 16),
          HostBonusCard(
            task: state.bonusTask,
            points: state.bonusPoints,
            resolved: state.bonusTaskResolved,
            completed: state.bonusTaskCompleted,
            onComplete: () => onResolveBonus(true),
            onNotComplete: () => onResolveBonus(false),
          ),
        ],

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.questionIndex > 0 ? onPrevious : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Câu trước'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: state.finished ? null : onNext,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  state.questionIndex + 1 >= questionCount
                      ? 'Kết thúc'
                      : 'Câu tiếp',
                ),
              ),
            ),
          ],
        ),

        if (state.finished) ...[
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Đã hết câu hỏi của trò chơi này!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onReturnToLobby,
              icon: const Icon(Icons.home),
              label: const Text('Về danh sách trò chơi'),
            ),
          ),
        ],
      ],
    );
  }
}