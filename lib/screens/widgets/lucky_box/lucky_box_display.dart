import 'package:flutter/material.dart';

import '../../../models/game_state.dart';

class LuckyBoxDisplay extends StatefulWidget {
  final GameState state;

  const LuckyBoxDisplay({
    super.key,
    required this.state,
  });

  @override
  State<LuckyBoxDisplay> createState() => _LuckyBoxDisplayState();
}

class _LuckyBoxDisplayState extends State<LuckyBoxDisplay> {
  static const Color _gold = Color(0xFFFFD166);
  static const Color _purple = Color(0xFF49368A);
  static const Color _dark = Color(0xFF292947);

  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOpenedBox();
    });
  }

  @override
  void didUpdateWidget(covariant LuckyBoxDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.openedLuckyBoxId !=
        widget.state.openedLuckyBoxId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkOpenedBox();
      });
    }
  }

  void _checkOpenedBox() {
    if (!mounted) return;

    final openedId = widget.state.openedLuckyBoxId;

    if (openedId == null) {
      if (_dialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        _dialogShowing = false;
      }
      return;
    }

    if (_dialogShowing) return;

    final index = _findBoxIndex(
      widget.state.luckyBoxes,
      openedId,
    );

    if (index < 0) return;

    _showOpenedBoxDialog(
      widget.state.luckyBoxes[index],
    );
  }

  void _showOpenedBoxDialog(Map<String, dynamic> box) {
    if (!mounted || _dialogShowing) return;

    _dialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            child: _buildOpenedBox(box),
          ),
        );
      },
    ).then((_) {
      _dialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final boxes = widget.state.luckyBoxes;

    final openedIndex = _findBoxIndex(
      boxes,
      widget.state.openedLuckyBoxId,
    );

    final selectedIndex = _findBoxIndex(
      boxes,
      widget.state.selectedLuckyBoxId,
    );

    return Column(
      children: [
        const Text(
          '🎁 CHIẾC HỘP MAY MẮN 🎁',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _gold,
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Hãy cùng khám phá điều bất ngờ!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: boxes.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemBuilder: (context, index) {
              final box = boxes[index];
              final id = _boxId(box, index);

              final isOpened =
              widget.state.openedLuckyBoxIds.contains(id);

              final isSelected = selectedIndex == index;
              final isActive = openedIndex == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  color: isOpened
                      ? const Color(0xFF202035)
                      : isActive
                      ? _purple
                      : _dark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? _gold
                        : isSelected
                        ? Colors.orangeAccent
                        : Colors.white24,
                    width: isActive || isSelected ? 4 : 2,
                  ),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 3,
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOpened
                          ? Icons.lock_open_rounded
                          : Icons.card_giftcard_rounded,
                      color: isOpened ? Colors.white30 : _gold,
                      size: 42,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'HỘP ${index + 1}',
                      style: TextStyle(
                        color: isOpened ? Colors.white30 : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    if (isActive)
                      const Text(
                        '✨ ĐANG MỞ ✨',
                        style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (isOpened)
                      const Text(
                        'ĐÃ MỞ',
                        style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOpenedBox(Map<String, dynamic> box) {
    final title = box['title']?.toString() ?? 'Bất ngờ!';
    final content = box['content']?.toString() ?? '';
    final points = _toInt(box['points']);
    final type = box['type']?.toString() ?? '';

    String rewardText;

    switch (type) {
      case 'bonus':
        rewardText = '🎉 PHẦN THƯỞNG MAY MẮN!';
        break;
      case 'mystery':
        rewardText = '🎁 PHẦN THƯỞNG BÍ ẨN!';
        break;
      case 'challenge':
        rewardText = '⭐ THỬ THÁCH ĐANG CHỜ BẠN!';
        break;
      default:
        rewardText = '✨ CÙNG KHÁM PHÁ BẤT NGỜ!';
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 850),
      padding: const EdgeInsets.symmetric(
        horizontal: 36,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF49368A),
            Color(0xFF292947),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _gold,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.celebration,
            color: _gold,
            size: 64,
          ),

          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _gold,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            content.isEmpty ? 'Hãy cùng khám phá bất ngờ!' : content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          if (type != 'mystery')
            Text(
              '+$points ĐIỂM',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _gold,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),

          const SizedBox(height: 12),

          Text(
            rewardText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (widget.state.luckyRewardAwarded) ...[
            const SizedBox(height: 20),
            const Text(
              '🏆 ĐÃ NHẬN ĐIỂM THƯỞNG!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ] else if (widget.state.luckyChallengeResolved) ...[
            const SizedBox(height: 20),
            const Text(
              '✨ THỬ THÁCH ĐÃ KẾT THÚC',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _gold,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _findBoxIndex(
      List<Map<String, dynamic>> boxes,
      int? id,
      ) {
    if (id == null) return -1;

    return boxes.indexWhere(
          (box) => _boxId(box, boxes.indexOf(box)) == id,
    );
  }

  int _boxId(Map<String, dynamic> box, int index) {
    return _toInt(box['id'], fallback: index);
  }

  int _toInt(
      dynamic value, {
        int fallback = 0,
      }) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}