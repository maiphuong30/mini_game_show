import 'package:flutter/material.dart';

class HostScoreboard extends StatelessWidget {
  final List<String> teams;
  final List<int> scores;
  final void Function(String team, int amount) onChangeScore;

  const HostScoreboard({
    super.key,
    required this.teams,
    required this.scores,
    required this.onChangeScore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: teams.asMap().entries.map((entry) {
        final teamIndex = entry.key;
        final team = entry.value;
        final score = teamIndex < scores.length ? scores[teamIndex] : 0;

        return Card(
          child: ListTile(
            title: Text(team),
            subtitle: Text('Điểm: $score'),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'Trừ 10 điểm',
                  onPressed: () => onChangeScore(team, -10),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  tooltip: 'Cộng 10 điểm',
                  onPressed: () => onChangeScore(team, 10),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}