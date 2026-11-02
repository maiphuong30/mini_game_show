import 'package:flutter/material.dart';

import '../../../models/game_state.dart';

class DisplayScoreboard extends StatelessWidget {
  final GameState state;

  const DisplayScoreboard({
    super.key,
    required this.state,
  });

  static const List<Color> _colors = [
    Color(0xFF3986FF),
    Color(0xFFFF9F43),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}