import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import '../models/game_state.dart';

class GameSyncService extends ChangeNotifier {
  static const String _storageKey = 'mini_game_show_state';

  GameState _state = const GameState();

  GameState get state => _state;

  GameSyncService() {
    _loadInitialState();

    // Nhận cập nhật từ tab trình duyệt khác (màn hình TV).
    html.window.onStorage.listen((event) {
      if (event.key != _storageKey || event.newValue == null) {
        return;
      }

      try {
        final decoded = jsonDecode(event.newValue!);

        if (decoded is Map<String, dynamic>) {
          _state = GameState.fromJson(decoded);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Không thể đồng bộ trạng thái trò chơi: $e');
      }
    });
  }

  /// Đọc trạng thái đã lưu khi khởi tạo.
  void _loadInitialState() {
    try {
      final raw = html.window.localStorage[_storageKey];

      if (raw == null || raw.isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        _state = GameState.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Không thể tải trạng thái trò chơi: $e');
      _state = const GameState();
    }
  }

  /// Cập nhật trạng thái và đồng bộ sang tab trình chiếu.
  void update(GameState newState) {
    _state = newState;

    try {
      html.window.localStorage[_storageKey] =
          jsonEncode(newState.toJson());
    } catch (e) {
      debugPrint('Không thể lưu trạng thái trò chơi: $e');
    }

    notifyListeners();
  }

  /// Đưa trò chơi về trạng thái ban đầu.
  void reset() {
    update(const GameState());
  }
}