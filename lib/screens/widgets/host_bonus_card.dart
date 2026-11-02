import 'package:flutter/material.dart';

class HostBonusCard extends StatelessWidget {
  final String task;
  final int points;
  final bool resolved;
  final bool completed;
  final VoidCallback onComplete;
  final VoidCallback onNotComplete;

  const HostBonusCard({
    super.key,
    required this.task,
    required this.points,
    required this.resolved,
    required this.completed,
    required this.onComplete,
    required this.onNotComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎁 NHIỆM VỤ BONUS ĐÃ MỞ KHÓA',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(task),
            const SizedBox(height: 8),
            Text('Điểm thưởng: +$points'),
            const SizedBox(height: 12),
            if (!resolved) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Hoàn thành - Cộng điểm thưởng'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onNotComplete,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Không hoàn thành'),
                ),
              ),
            ] else
              Text(
                completed
                    ? 'Đã hoàn thành nhiệm vụ, cộng $points điểm.'
                    : 'Nhiệm vụ chưa hoàn thành, không cộng điểm thưởng.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: completed ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}