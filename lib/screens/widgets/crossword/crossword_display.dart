
import 'package:flutter/material.dart';

import '../../../models/game_state.dart';

class CrosswordDisplay extends StatelessWidget {
  final GameState state;

  const CrosswordDisplay({
    super.key,
    required this.state,
  });

  String _normalize(String value) {
    const vietnamese = {
      'Á': 'A', 'À': 'A', 'Ả': 'A', 'Ã': 'A', 'Ạ': 'A',
      'Ă': 'A', 'Ắ': 'A', 'Ằ': 'A', 'Ẳ': 'A', 'Ẵ': 'A', 'Ặ': 'A',
      'Â': 'A', 'Ấ': 'A', 'Ầ': 'A', 'Ẩ': 'A', 'Ẫ': 'A', 'Ậ': 'A',
      'É': 'E', 'È': 'E', 'Ẻ': 'E', 'Ẽ': 'E', 'Ẹ': 'E',
      'Ê': 'E', 'Ế': 'E', 'Ề': 'E', 'Ể': 'E', 'Ễ': 'E', 'Ệ': 'E',
      'Í': 'I', 'Ì': 'I', 'Ỉ': 'I', 'Ĩ': 'I', 'Ị': 'I',
      'Ó': 'O', 'Ò': 'O', 'Ỏ': 'O', 'Õ': 'O', 'Ọ': 'O',
      'Ô': 'O', 'Ố': 'O', 'Ồ': 'O', 'Ổ': 'O', 'Ỗ': 'O', 'Ộ': 'O',
      'Ơ': 'O', 'Ớ': 'O', 'Ờ': 'O', 'Ở': 'O', 'Ỡ': 'O', 'Ợ': 'O',
      'Ú': 'U', 'Ù': 'U', 'Ủ': 'U', 'Ũ': 'U', 'Ụ': 'U',
      'Ư': 'U', 'Ứ': 'U', 'Ừ': 'U', 'Ử': 'U', 'Ữ': 'U', 'Ự': 'U',
      'Ý': 'Y', 'Ỳ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y', 'Ỵ': 'Y',
      'Đ': 'D',
    };

    final upper = value.toUpperCase();

    return upper
        .split('')
        .map((char) => vietnamese[char] ?? char)
        .where((char) => RegExp(r'[A-Z0-9]').hasMatch(char))
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final rows = state.crosswordRows;

    if (rows.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'Đang chuẩn bị ô chữ...',
            style: TextStyle(color: Colors.white70, fontSize: 26),
          ),
        ),
      );
    }

    final normalizedAnswers = rows
        .map((row) => _normalize(row['answer']?.toString() ?? ''))
        .toList();

    final keyword = _normalize(state.crosswordKeyword);

    final keywordIndexes = rows.map((row) {
      final value = row['keywordIndex'];
      return value is num ? value.toInt() : 0;
    }).toList();

    final verticalColumn = keywordIndexes.reduce(
          (a, b) => a > b ? a : b,
    );

    final starts = List.generate(
      rows.length,
          (i) => verticalColumn - keywordIndexes[i],
    );

    final columnCount = List.generate(rows.length, (i) {
      return starts[i] + normalizedAnswers[i].length;
    }).reduce((a, b) => a > b ? a : b);

    final revealed = state.revealedCrosswordRows.toSet();

    final selectedIndex = state.selectedCrosswordRow;
    final hasSelectedRow = selectedIndex != null &&
        selectedIndex >= 0 &&
        selectedIndex < rows.length;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final cellSize = ((availableWidth - 40) / columnCount)
              .clamp(28.0, 52.0);

          return SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'GIẢI Ô CHỮ',
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 18),

                // Bảng ô chữ
                Center(
                  child: Column(
                    children: List.generate(rows.length, (rowIndex) {
                      final answer = normalizedAnswers[rowIndex];
                      final start = starts[rowIndex];
                      final isRevealed = revealed.contains(rowIndex);

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(columnCount, (columnIndex) {
                          final answerIndex = columnIndex - start;

                          final isAnswerCell = answerIndex >= 0 &&
                              answerIndex < answer.length;

                          final isKeywordCell =
                              columnIndex == verticalColumn;

                          // Mỗi vị trí đều có cùng kích thước.
                          return SizedBox(
                            width: cellSize,
                            height: cellSize,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: isAnswerCell
                                  ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isKeywordCell
                                      ? const Color(0xFFFFD166)
                                      : const Color(0xFF39345D),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isKeywordCell
                                        ? const Color(0xFFFFE7A3)
                                        : Colors.white54,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  isRevealed ||
                                      (state.crosswordKeywordRevealed &&
                                          isKeywordCell)
                                      ? answer[answerIndex]
                                      : '',
                                  style: TextStyle(
                                    color: isKeywordCell
                                        ? const Color(0xFF24164B)
                                        : Colors.white,
                                    fontSize: cellSize * 0.55,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )
                                  : const SizedBox.expand(),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 22),

                // Chỉ hiển thị gợi ý của hàng đang được chọn.
                if (hasSelectedRow)
                  Builder(
                    builder: (context) {
                      final row = rows[selectedIndex];
                      final isRevealed = revealed.contains(selectedIndex);
                      final clue = row['clue']?.toString() ?? '';

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isRevealed
                              ? const Color(0xFF245B49)
                              : const Color(0xFF292947),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isRevealed
                                ? Colors.greenAccent
                                : const Color(0xFFFFD166),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD166),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                '${selectedIndex + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF24164B),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    clue,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isRevealed) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      row['answer']?.toString() ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFFFFD166),
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isRevealed)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                                size: 28,
                              ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF292947),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'Chờ chọn hàng ngang...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                // Từ khóa dọc
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF49368A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD166),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TỪ KHÓA',
                        style: TextStyle(
                          color: Color(0xFFFFD166),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.crosswordKeywordRevealed
                            ? state.crosswordKeyword
                            : List.generate(keyword.length, (index) {
                          final found = rows.asMap().entries.any(
                                (entry) {
                              final rowIndex = entry.key;

                              if (!revealed.contains(rowIndex)) {
                                return false;
                              }

                              final answer = normalizedAnswers[rowIndex];
                              final answerIndex =
                              keywordIndexes[rowIndex];

                              return answerIndex >= 0 &&
                                  answerIndex < answer.length &&
                                  answer[answerIndex] == keyword[index];
                            },
                          );

                          return found ? keyword[index] : '＿';
                        }).join(' '),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
