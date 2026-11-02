import 'package:flutter/material.dart';

import '../../../services/game_sync_service.dart';

class RebusHost extends StatelessWidget {
  final GameSyncService sync;
  final VoidCallback onAwardCorrect;

  const RebusHost({
    super.key,
    required this.sync,
    required this.onAwardCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final state = sync.state;
    final chars = state.rebusAnswer.runes
        .map((rune) => String.fromCharCode(rune))
        .toList();

    if (chars.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedTeamName =
    state.selectedTeam >= 0 &&
        state.selectedTeam < state.teams.length
        ? state.teams[state.selectedTeam]
        : 'Đội được chọn';

    // ĐÃ CÔNG BỐ ĐÁP ÁN
    if (state.showAnswer) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 42,
              ),
              const SizedBox(height: 8),
              const Text(
                'ĐÁP ÁN CHÍNH XÁC',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.rebusAnswer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Đã cộng điểm cho $selectedTeamName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'MỞ CHỮ CÁI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn từng ô chữ để gợi ý cho các đội.',
            ),
            const SizedBox(height: 16),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 8,
              children: List.generate(chars.length, (index) {
                final char = chars[index];
                final isRevealed =
                state.revealedRebusPositions.contains(index);

                // Giữ nguyên khoảng trắng và ký tự phân cách.
                if (char.trim().isEmpty) {
                  return const SizedBox(width: 12);
                }

                return SizedBox(
                  width: 42,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isRevealed
                        ? null
                        : () {
                      final positions =
                      List<int>.from(
                        state.revealedRebusPositions,
                      );

                      positions.add(index);

                      sync.update(
                        state.copyWith(
                          revealedRebusPositions: positions,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: isRevealed
                          ? Colors.deepPurple
                          : Colors.white,
                      foregroundColor: isRevealed
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                    child: Text(
                      isRevealed ? char : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.scoreAwarded
                    ? null
                    : onAwardCorrect,
                icon: const Icon(Icons.campaign),
                label: const Text(
                  'Đội trả lời đúng - Cộng điểm',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}