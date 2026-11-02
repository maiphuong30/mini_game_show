
import 'package:flutter/material.dart';

import '../../../models/game_state.dart';
import '../../../services/game_sync_service.dart';

class CrosswordHost extends StatelessWidget {
  final GameSyncService sync;

  const CrosswordHost({
    super.key,
    required this.sync,
  });

  GameState get state => sync.state;

  void _selectRow(int index) {
    if (state.revealedCrosswordRows.contains(index)) return;

    sync.update(
      state.copyWith(
        selectedCrosswordRow: index,
        clearSelectedAnswer: true,
      ),
    );
  }

  void _selectTeam(int index) {
    if (index < 0 || index >= state.teams.length) return;

    sync.update(
      state.copyWith(selectedTeam: index),
    );
  }

  void _revealRow() {
    final index = state.selectedCrosswordRow;

    if (index == null ||
        index < 0 ||
        index >= state.crosswordRows.length ||
        state.revealedCrosswordRows.contains(index)) {
      return;
    }

    final scores = List<int>.from(state.scores);
    final teamIndex = state.selectedTeam;

    final rawPoints = state.crosswordRows[index]['points'];
    final points = rawPoints is num ? rawPoints.toInt() : 20;

    if (teamIndex >= 0 && teamIndex < scores.length) {
      scores[teamIndex] += points;
    }

    final revealed = List<int>.from(state.revealedCrosswordRows)
      ..add(index);

    sync.update(
      state.copyWith(
        scores: scores,
        revealedCrosswordRows: revealed,
        clearSelectedCrosswordRow: true,
      ),
    );
  }

  void _revealKeyword() {
    if (state.crosswordKeywordRevealed) return;

    final scores = List<int>.from(state.scores);
    final teamIndex = state.selectedTeam;

    final rawPoints = state.crosswordRows.isNotEmpty
        ? state.crosswordRows.first['keywordPoints']
        : null;

    // Điểm từ khóa được lưu riêng trong cấu hình câu đố.
    final points = rawPoints is num ? rawPoints.toInt() : 50;

    if (!state.crosswordKeywordAwarded &&
        teamIndex >= 0 &&
        teamIndex < scores.length) {
      scores[teamIndex] += points;
    }

    sync.update(
      state.copyWith(
        scores: scores,
        crosswordKeywordRevealed: true,
        crosswordKeywordAwarded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sync,
      builder: (context, _) {
        final selectedIndex = state.selectedCrosswordRow;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn đội trả lời',
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
                  onSelected: (_) => _selectTeam(entry.key),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              'Các câu hàng ngang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...List.generate(state.crosswordRows.length, (index) {
              final row = state.crosswordRows[index];
              final isRevealed =
              state.revealedCrosswordRows.contains(index);
              final isSelected = selectedIndex == index;

              return Card(
                color: isSelected
                    ? Colors.deepPurple.shade50
                    : null,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    row['clue']?.toString() ?? '',
                  ),
                  subtitle: isRevealed
                      ? Text(
                    'Đáp án: ${row['answer']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : Text(
                    '${row['points'] ?? 20} điểm',
                  ),
                  trailing: isRevealed
                      ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                      : isSelected
                      ? const Icon(
                    Icons.radio_button_checked,
                    color: Colors.deepPurple,
                  )
                      : const Icon(Icons.radio_button_unchecked),
                  onTap: isRevealed ? null : () => _selectRow(index),
                ),
              );
            }),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedIndex == null
                    ? null
                    : _revealRow,
                icon: const Icon(Icons.visibility),
                label: const Text('Mở đáp án hàng ngang và cộng điểm'),
              ),
            ),

            const Divider(height: 32),

            const Text(
              'Từ khóa hàng dọc',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (state.crosswordKeywordRevealed)
              Text(
                state.crosswordKeyword,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: 4,
                ),
              )
            else
              const Text(
                'Từ khóa đang được giữ bí mật.',
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.crosswordKeywordRevealed
                    ? null
                    : _revealKeyword,
                icon: const Icon(Icons.key),
                label: const Text('Xác nhận đoán đúng từ khóa'),
              ),
            ),
          ],
        );
      },
    );
  }
}
