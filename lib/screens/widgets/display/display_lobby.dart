import 'package:flutter/material.dart';

import '../../../models/game_state.dart';

class DisplayLobby extends StatelessWidget {
  final GameState state;

  const DisplayLobby({
    super.key,
    required this.state,
  });

  static const Map<String, String> _gameModes = {
    'quiz': 'Trắc nghiệm',
    'lucky': 'Hộp may mắn',
    'rebus': 'Đuổi hình bắt chữ',
    'vietnamese': 'Vua tiếng Việt',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15152B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  '🎉 MINI GAME SHOW 🎉',
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
                      height: 170,
                      padding: const EdgeInsets.all(16),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _gameIcon(entry.key),
                            size: 36,
                            color: played
                                ? Colors.white30
                                : const Color(0xFFFFD166),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: played ? Colors.white38 : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            played
                                ? '✓ ĐÃ CHƠI'
                                : selected
                                ? 'ĐANG ĐƯỢC CHỌN'
                                : 'SẴN SÀNG',
                            textAlign: TextAlign.center,
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
      case 'vietnamese':
        return Icons.menu_book;
      default:
        return Icons.games;
    }
  }
}