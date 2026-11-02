
import 'dart:convert';

import 'package:flutter/services.dart';

class QuestionService {
  static const String _quizPath = 'assets/questions/quiz.json';
  static const String _luckyBoxPath = 'assets/questions/lucky_box.json';
  static const String _rebusPath = 'assets/questions/rebus.json';
  static const String _vietnamesePath = 'assets/questions/vietnamese.json';
  static const String _bonusPath = 'assets/questions/bonus.json';
  static const String _crosswordPath = 'assets/questions/crossword.json';

  static final Map<String, List<Map<String, dynamic>>> _cache = {};

  static Future<List<Map<String, dynamic>>> _loadJson(
      String path,
      ) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(path);
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        throw FormatException('Dữ liệu JSON không hợp lệ: $path');
      }

      final List<Map<String, dynamic>> result = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      _cache[path] = result;
      return result;
    } catch (e) {
      throw Exception('Không thể tải dữ liệu từ $path: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getQuizQuestions() {
    return _loadJson(_quizPath);
  }

  static Future<List<Map<String, dynamic>>> getLuckyBoxes() {
    return _loadJson(_luckyBoxPath);
  }

  static Future<List<Map<String, dynamic>>> getRebusQuestions() {
    return _loadJson(_rebusPath);
  }

  static Future<List<Map<String, dynamic>>> getVietnameseQuestions() {
    return _loadJson(_vietnamesePath);
  }

  static Future<List<Map<String, dynamic>>> getBonusQuestions() {
    return _loadJson(_bonusPath);
  }

  static Future<List<Map<String, dynamic>>> getCrosswordQuestions() {
    return _loadJson(_crosswordPath);
  }

  static Future<List<Map<String, dynamic>>> getQuestions(
      String gameMode,
      ) async {
    switch (gameMode) {
      case 'quiz':
        return getQuizQuestions();

      case 'lucky':
      case 'lucky_box':
        return getLuckyBoxes();

      case 'rebus':
        return getRebusQuestions();

      case 'vietnamese':
        return getVietnameseQuestions();

      case 'bonus':
        return getBonusQuestions();

      case 'crossword':
        return getCrosswordQuestions();

      default:
        return [];
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}
