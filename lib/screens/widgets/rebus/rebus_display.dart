import 'package:flutter/material.dart';

import '../../../models/game_state.dart';

class RebusDisplay extends StatelessWidget {
  final GameState state;

  const RebusDisplay({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final chars = state.rebusAnswer.runes
        .map((rune) => String.fromCharCode(rune))
        .toList();

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight =
          (constraints.maxHeight * 0.58)
              .clamp(100.0, 340.0);

          final fontSize = chars.length > 18 ? 24.0 : 32.0;
          final boxWidth = chars.length > 18 ? 34.0 : 46.0;

          return Column(
            children: [
              const SizedBox(height: 8),

              Text(
                'CÂU ${state.questionIndex + 1}',
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                state.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // HÌNH ẢNH
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 850,
                      maxHeight: imageHeight,
                    ),
                    child: _buildImage(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // CÁC Ô CHỮ ĐÁP ÁN
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 8,
                children: List.generate(chars.length, (index) {
                  final char = chars[index];

                  if (char.trim().isEmpty) {
                    return const SizedBox(width: 12);
                  }

                  final isRevealed = state.showAnswer ||
                      state.revealedRebusPositions.contains(index);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: boxWidth,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isRevealed
                          ? Colors.deepPurple
                          : const Color(0xFF292947),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isRevealed
                            ? const Color(0xFFFFD166)
                            : Colors.white54,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      isRevealed ? char : '?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              if (state.showAnswer)
                const Text(
                  '🎉 ĐÁP ÁN CHÍNH XÁC!',
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else
                Text(
                  'ĐÃ MỞ '
                      '${state.revealedRebusPositions.length} '
                      'CHỮ CÁI',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    final image = state.image.trim();

    if (image.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF292947),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.image,
          color: Colors.white38,
          size: 80,
        ),
      );
    }

    final isNetworkImage =
        image.startsWith('http://') ||
            image.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: isNetworkImage
          ? Image.network(
        image,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _imageError();
        },
      )
          : Image.asset(
        image,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _imageError();
        },
      ),
    );
  }

  Widget _imageError() {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xFF292947),
      child: const Icon(
        Icons.broken_image,
        color: Colors.white38,
        size: 80,
      ),
    );
  }
}