
import 'package:flutter/material.dart';

import '../models/game_state.dart';
import 'widgets/quiz/quiz_display.dart';
import 'widgets/lucky_box/lucky_box_display.dart';
import 'widgets/rebus/rebus_display.dart';
import 'widgets/crossword/crossword_display.dart';

class DisplayScreen extends StatelessWidget {
  final GameState state;

  const DisplayScreen({
    super.key,
    required this.state,
  });

  static const Map<String, String> _gameModes = {
    'quiz': 'Trắc nghiệm',
    'lucky': 'Hộp may mắn',
    'rebus': 'Đuổi hình bắt chữ',
    'crossword': 'Giải ô chữ',
  };

  static const List<Color> _colors = [
    Color(0xFF3986FF),
    Color(0xFFFF9F43),
  ];

  @override
  Widget build(BuildContext context) {
    if (state.isLobby) {
      return _buildLobby();
    }

    return _buildGame();
  }

  Widget _buildLobby() {
    return Scaffold(
      backgroundColor: const Color(0xFF15152B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  '🎉 ĐẤU TRƯỜNG TRI THỨC 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CÙNG KHÁM PHÁ CÁC TRÒ CHƠI!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 36),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: _gameModes.entries.map((entry) {
                    final played = state.playedGames.contains(entry.key);
                    final selected = state.gameMode == entry.key;

                    return Container(
                      width: 260,
                      height: 150,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: played
                            ? const Color(0xFF29293D)
                            : selected
                            ? const Color(0xFF49368A)
                            : const Color(0xFF292947),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: played
                              ? Colors.white12
                              : selected
                              ? const Color(0xFFFFD166)
                              : Colors.white24,
                          width: selected && !played ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _gameIcon(entry.key),
                            size: 34,
                            color: played
                                ? Colors.white30
                                : const Color(0xFFFFD166),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.value,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: played ? Colors.white38 : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            played
                                ? '✓ ĐÃ CHƠI'
                                : selected
                                ? 'ĐANG ĐƯỢC CHỌN'
                                : 'SẴN SÀNG',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              color: played
                                  ? Colors.white38
                                  : const Color(0xFFFFD166),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),
                const Text(
                  'MC đang chuẩn bị trò chơi...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _gameIcon(String mode) {
    switch (mode) {
      case 'quiz':
        return Icons.quiz;
      case 'lucky':
        return Icons.card_giftcard;
      case 'rebus':
        return Icons.image_search;
      case 'crossword':
        return Icons.grid_on;
      default:
        return Icons.games;
    }
  }

  Widget _buildGame() {
    return Scaffold(
      backgroundColor: const Color(0xFF15152B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                '🎉 MINI GAME SHOW 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: List.generate(state.teams.length, (i) {
                  final isSelectedTeam = i == state.selectedTeam;

                  return Expanded(
                    child: AnimatedScale(
                      scale: isSelectedTeam ? 1.035 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelectedTeam
                              ? const Color(0xFF554A87)
                              : _colors[i % _colors.length],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelectedTeam
                                ? const Color(0xFFFFD166)
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelectedTeam
                              ? [
                            BoxShadow(
                              color: const Color(0xFFFFD166)
                                  .withValues(alpha: 0.45),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSelectedTeam) ...[
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Color(0xFFFFD166),
                                    size: 26,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Text(
                                    state.teams[i],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${i < state.scores.length ? state.scores[i] : 0} điểm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              if (state.finished) ...[
                const Spacer(),
                const Text(
                  '🎉 KẾT THÚC TRÒ CHƠI! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
              ] else if (state.gameMode == 'quiz') ...[
                Expanded(
                  child: QuizDisplay(state: state),
                ),
              ] else if (state.gameMode == 'lucky') ...[
                Expanded(
                  child: LuckyBoxDisplay(state: state),
                ),
              ] else if (state.gameMode == 'rebus') ...[
                RebusDisplay(state: state),
              ] else if (state.gameMode == 'crossword') ...[
                CrosswordDisplay(state: state),
              ] else ...[
                _buildQuestionGame(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionGame() {
    final hasSelectedAnswer = state.selectedAnswer != null &&
        state.selectedAnswer! >= 0 &&
        state.selectedAnswer! < state.answers.length;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 12),
            Text(
              state.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (state.answers.isNotEmpty)
              GridView.builder(
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
                  final isSelected = hasSelectedAnswer &&
                      state.selectedAnswer == index;
                  final isCorrect = state.showAnswer &&
                      state.correctAnswer == index;

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
              ),
          ],
        ),
      ),
    );
  }
}
