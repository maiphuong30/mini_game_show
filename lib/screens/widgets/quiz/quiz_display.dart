
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/game_state.dart';

class QuizDisplay extends StatelessWidget {
  final GameState state;

  const QuizDisplay({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedAnswer = state.selectedAnswer != null &&
        state.selectedAnswer! >= 0 &&
        state.selectedAnswer! < state.answers.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = math.min(
          constraints.maxHeight * 0.28,
          180.0,
        );

        return Stack(
          children: [
            Column(
              children: [
                Text(
                  'CÂU ${state.questionIndex + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  state.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Ảnh được giới hạn chiều cao để không chiếm chỗ đáp án.
                if (state.image.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Image.asset(
                      state.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Không thể tải hình ảnh',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Phần đáp án có vùng riêng, không bị ảnh đẩy khuất.
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (state.answers.isNotEmpty)
                          _buildAnswers(hasSelectedAnswer),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Popup Bonus chỉ hiển thị trên màn hình TV.
            if (state.bonusUnlocked && !state.bonusTaskResolved)
              Positioned.fill(
                child: _buildBonus(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAnswers(bool hasSelectedAnswer) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(4),
      itemCount: state.answers.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final isSelected =
            hasSelectedAnswer && state.selectedAnswer == index;

        final isCorrect =
            state.showAnswer && state.correctAnswer == index;

        Color backgroundColor = const Color(0xFF292947);
        Color borderColor = Colors.white24;

        if (isSelected && !state.showAnswer) {
          backgroundColor = const Color(0xFF554A87);
          borderColor = const Color(0xFFFFD166);
        }

        if (state.showAnswer && isCorrect) {
          backgroundColor = Colors.green;
          borderColor = Colors.greenAccent;
        } else if (state.showAnswer && isSelected) {
          backgroundColor = Colors.red.shade900;
          borderColor = Colors.redAccent;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected || isCorrect ? 3 : 2,
            ),
            boxShadow: isSelected && !state.showAnswer
                ? [
              BoxShadow(
                color: const Color(0xFFFFD166)
                    .withValues(alpha: 0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${String.fromCharCode(65 + index)}. ${state.answers[index]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (state.showAnswer && isCorrect) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 28,
                ),
              ],

              if (state.showAnswer &&
                  isSelected &&
                  !isCorrect) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBonus() {
    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 650,
            constraints: const BoxConstraints(maxWidth: 650),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF49368A),
                  Color(0xFF24164B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFD166),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD166)
                      .withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  color: Color(0xFFFFD166),
                  size: 60,
                ),
                const SizedBox(height: 12),
                const Text(
                  '🎁 NHIỆM VỤ BONUS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.bonusTask,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '+${state.bonusPoints} ĐIỂM',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hãy cùng hoàn thành thử thách nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
