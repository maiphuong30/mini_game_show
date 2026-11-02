
import 'package:flutter/material.dart';

import '../../../models/game_state.dart';
import '../../../services/game_sync_service.dart';

class LuckyBoxHost extends StatelessWidget {
  final GameSyncService sync;

  const LuckyBoxHost({
    super.key,
    required this.sync,
  });

  void _updateGame(GameState game) {
    sync.update(game);
  }

  // Chọn đội chơi.
  void _selectTeam(GameState game, int teamIndex) {
    if (game.openedLuckyBoxId != null) return;

    _updateGame(
      game.copyWith(selectedTeam: teamIndex),
    );
  }

  // Chọn hộp chưa mở.
  void _selectBox(GameState game, int boxId) {
    if (game.openedLuckyBoxId != null) return;
    if (game.openedLuckyBoxIds.contains(boxId)) return;

    _updateGame(
      game.copyWith(
        selectedLuckyBoxId: boxId,
        clearOpenedLuckyBox: true,
        luckyRewardAwarded: false,
        luckyChallengeResolved: false,
      ),
    );
  }

  // Cộng điểm cho đội.
  GameState _addPoints(
      GameState game,
      int teamIndex,
      int points,
      ) {
    final scores = List<int>.from(game.scores);

    if (teamIndex < 0 || teamIndex >= scores.length) {
      return game;
    }

    scores[teamIndex] += points;

    return game.copyWith(scores: scores);
  }

  // Mở hộp.
  void _openBox(GameState game) {
    final boxId = game.selectedLuckyBoxId;

    if (boxId == null) return;
    if (game.openedLuckyBoxId != null) return;
    if (game.openedLuckyBoxIds.contains(boxId)) return;

    final box = game.luckyBoxes.firstWhere(
          (item) => item['id'] == boxId,
    );

    final type = box['type'] as String? ?? '';
    final points = (box['points'] as num?)?.toInt() ?? 0;

    var updatedGame = game.copyWith(
      openedLuckyBoxId: boxId,
      openedLuckyBoxIds: [
        ...game.openedLuckyBoxIds,
        boxId,
      ],
      luckyRewardAwarded: false,
      luckyChallengeResolved: false,
    );

    // Hộp thưởng: cộng điểm ngay khi mở.
    if (type == 'bonus') {
      updatedGame = _addPoints(
        updatedGame,
        game.selectedTeam,
        points,
      ).copyWith(
        luckyRewardAwarded: true,
      );
    }

    _updateGame(updatedGame);
  }

  // Xử lý thử thách.
  void _resolveChallenge(
      GameState game,
      bool completed,
      ) {
    if (game.openedLuckyBoxId == null) return;
    if (game.luckyChallengeResolved) return;

    final box = game.luckyBoxes.firstWhere(
          (item) => item['id'] == game.openedLuckyBoxId,
    );

    final points = (box['points'] as num?)?.toInt() ?? 0;

    var updatedGame = game;

    if (completed) {
      updatedGame = _addPoints(
        updatedGame,
        game.selectedTeam,
        points,
      );
    }

    _updateGame(
      updatedGame.copyWith(
        luckyChallengeResolved: true,
        luckyRewardAwarded: completed,
      ),
    );
  }

  // Xử lý hộp bí ẩn.
  void _resolveMystery(
      GameState game,
      int points,
      ) {
    if (game.openedLuckyBoxId == null) return;
    if (game.luckyChallengeResolved) return;

    final updatedGame = _addPoints(
      game,
      game.selectedTeam,
      points,
    );

    _updateGame(
      updatedGame.copyWith(
        luckyRewardAwarded: true,
        luckyChallengeResolved: true,
      ),
    );
  }

  // Kiểm tra hộp đã được xử lý xong chưa.
  bool _canConfirm(GameState game) {
    if (game.openedLuckyBoxId == null) return false;

    final box = game.luckyBoxes.firstWhere(
          (item) => item['id'] == game.openedLuckyBoxId,
    );

    final type = box['type'] as String? ?? '';

    if (type == 'bonus') {
      return game.luckyRewardAwarded;
    }

    if (type == 'challenge' || type == 'mystery') {
      return game.luckyChallengeResolved;
    }

    return false;
  }

  // Xác nhận hoàn tất hộp hiện tại.
  void _confirmBox(GameState game) {
    if (!_canConfirm(game)) return;

    _updateGame(
      game.copyWith(
        clearSelectedLuckyBox: true,
        clearOpenedLuckyBox: true,
        luckyRewardAwarded: false,
        luckyChallengeResolved: false,
      ),
    );
  }

  // Kết thúc trò chơi.
  void _finishGame(GameState game) {
    if (game.openedLuckyBoxId != null) return;

    _updateGame(
      game.copyWith(
        finished: true,
        isLobby: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sync,
      builder: (context, _) {
        final game = sync.state;

        final boxes = game.luckyBoxes;
        final selectedId = game.selectedLuckyBoxId;
        final openedId = game.openedLuckyBoxId;

        final selectedBox = selectedId == null
            ? null
            : boxes.firstWhere(
              (box) => box['id'] == selectedId,
        );

        final openedBox = openedId == null
            ? null
            : boxes.firstWhere(
              (box) => box['id'] == openedId,
        );

        final opened = openedId != null;
        final canConfirm = _canConfirm(game);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🎁 CHIẾC HỘP MAY MẮN',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Chọn đội chơi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                game.teams.length,
                    (index) {
                  return ChoiceChip(
                    label: Text(game.teams[index]),
                    selected: game.selectedTeam == index,
                    onSelected: opened
                        ? null
                        : (_) => _selectTeam(game, index),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Chọn một chiếc hộp',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Grid tự mở rộng theo số lượng hộp.
            // Không tạo vùng cuộn riêng bên trong ListView của HostScreen.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: boxes.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) {
                final box = boxes[index];
                final id = box['id'] as int;

                final isOpened =
                game.openedLuckyBoxIds.contains(id);

                final isSelected = selectedId == id;

                return ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOpened
                              ? Icons.lock
                              : Icons.card_giftcard,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isOpened ? 'Đã mở' : 'Hộp $id',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  selected: isSelected,
                  onSelected: opened || isOpened
                      ? null
                      : (_) => _selectBox(game, id),
                  showCheckmark: false,
                  padding: const EdgeInsets.all(8),
                );
              },
            ),

            const SizedBox(height: 16),

            if (!opened)
              ElevatedButton.icon(
                onPressed: selectedBox == null
                    ? null
                    : () => _openBox(game),
                icon: const Icon(Icons.lock_open),
                label: const Text('MỞ HỘP'),
              ),

            if (openedBox != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        openedBox['title']?.toString() ??
                            'Hộp may mắn',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        openedBox['content']?.toString() ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 16),

                      if (openedBox['type'] == 'challenge') ...[
                        const Text(
                          'Kết quả thử thách:',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                game.luckyChallengeResolved
                                    ? null
                                    : () => _resolveChallenge(
                                  game,
                                  true,
                                ),
                                child: const Text('Hoàn thành'),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                game.luckyChallengeResolved
                                    ? null
                                    : () => _resolveChallenge(
                                  game,
                                  false,
                                ),
                                child: const Text('Chưa hoàn thành'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (openedBox['type'] == 'mystery') ...[
                        const Text(
                          'Chọn phần thưởng:',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [0, 10, 20, 50].map((points) {
                            return ElevatedButton(
                              onPressed:
                              game.luckyChallengeResolved
                                  ? null
                                  : () => _resolveMystery(
                                game,
                                points,
                              ),
                              child: Text(
                                points == 0
                                    ? '0 điểm'
                                    : '+$points điểm',
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      if (openedBox['type'] == 'bonus') ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Phần thưởng đã được cộng điểm.',
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: canConfirm
                            ? () => _confirmBox(game)
                            : null,
                        child: const Text('OK - TIẾP TỤC'),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: opened ? null : () => _finishGame(game),
              icon: const Icon(Icons.flag),
              label: const Text('KẾT THÚC TRÒ CHƠI'),
            ),
          ],
        );
      },
    );
  }
}
