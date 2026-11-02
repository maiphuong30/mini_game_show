
import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../services/game_sync_service.dart';
import '../services/question_service.dart';
import 'widgets/host_question_card.dart';
import 'widgets/host_scoreboard.dart';
import 'widgets/lucky_box/lucky_box_host.dart';
import 'widgets/quiz/quiz_host.dart';
import 'widgets/rebus/rebus_host.dart';
import 'widgets/crossword/crossword_host.dart';

class HostScreen extends StatefulWidget {
  final GameSyncService sync;

  const HostScreen({
    super.key,
    required this.sync,
  });

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  static const Map<String, String> _gameModes = {
    'quiz': 'Trắc nghiệm',
    'lucky': 'Hộp may mắn',
    'rebus': 'Đuổi hình bắt chữ',
    'crossword': 'Giải ô chữ',
  };

  List<Map<String, dynamic>> _questions = [];

  bool _isLoading = false;
  String? _loadError;

  String _selectedMode = 'quiz';

  GameSyncService get sync => widget.sync;
  GameState get state => sync.state;

  @override
  void initState() {
    super.initState();
    _selectedMode = state.gameMode;
  }

  // =========================================================
  // CHỌN VÀ BẮT ĐẦU TRÒ CHƠI
  // =========================================================

  void _selectMode(String mode) {
    if (_isLoading || state.playedGames.contains(mode)) return;

    setState(() {
      _selectedMode = mode;
      _loadError = null;
    });

    sync.update(
      state.copyWith(
        gameMode: mode,
        isLobby: true,
      ),
    );
  }

  Future<void> _startGame() async {
    if (_isLoading || state.playedGames.contains(_selectedMode)) {
      return;
    }

    await _loadQuestions(
      _selectedMode,
      startGame: true,
    );
  }

  Future<void> _loadQuestions(
      String mode, {
        bool startGame = false,
      }) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final questions = await QuestionService.getQuestions(mode);

      if (!mounted) return;

      setState(() {
        _questions = questions;
        _isLoading = false;
        _loadError = questions.isEmpty
            ? 'Chế độ này chưa có dữ liệu câu hỏi.'
            : null;
      });

      if (questions.isEmpty || !startGame) return;

      final playedGames = List<String>.from(state.playedGames);

      if (!playedGames.contains(mode)) {
        playedGames.add(mode);
      }

      sync.update(
        state.copyWith(
          gameMode: mode,
          playedGames: playedGames,
          isLobby: false,
        ),
      );

      _applyQuestion(
        0,
        questions: questions,
        mode: mode,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Không thể tải dữ liệu: $e';
      });
    }
  }

  // =========================================================
  // XỬ LÝ CÂU HỎI
  // =========================================================

  void _applyQuestion(
      int index, {
        List<Map<String, dynamic>>? questions,
        String? mode,
      }) {
    final list = questions ?? _questions;

    if (list.isEmpty || index < 0 || index >= list.length) return;

    final item = list[index];
    final gameMode = mode ?? state.gameMode;

    // =======================================================
    // CROSSWORD
    // =======================================================

    if (gameMode == 'crossword') {
      final keyword = item['keyword']?.toString() ?? '';

      final rows = (item['rows'] as List? ?? [])
          .map((row) => Map<String, dynamic>.from(row))
          .toList();

      // Đưa điểm từ khóa vào dữ liệu hàng đầu tiên
      // để CrosswordHost có thể sử dụng.
      final rawKeywordPoints = item['keywordPoints'];
      final keywordPoints = rawKeywordPoints is num
          ? rawKeywordPoints.toInt()
          : 50;

      if (rows.isNotEmpty) {
        rows[0]['keywordPoints'] = keywordPoints;
      }

      sync.update(
        state.copyWith(
          gameMode: 'crossword',
          isLobby: false,
          questionIndex: index,
          question: 'Giải ô chữ',
          clearImage: true,
          answers: [],
          clearCorrectAnswer: true,
          clearSelectedAnswer: true,
          selectedTeam: 0,
          showAnswer: false,
          scoreAwarded: false,
          finished: false,

          clearBonusTask: true,
          bonusUnlocked: false,
          bonusTaskResolved: false,
          bonusAwarded: false,
          bonusTaskCompleted: false,

          crosswordKeyword: keyword,
          crosswordRows: rows,
          revealedCrosswordRows: [],
          clearSelectedCrosswordRow: true,
          crosswordKeywordRevealed: false,
          crosswordKeywordAwarded: false,

          luckyBoxes: [],
          clearSelectedLuckyBox: true,
          clearOpenedLuckyBox: true,
          openedLuckyBoxIds: [],
          luckyRewardAwarded: false,
          luckyChallengeResolved: false,

          rebusAnswer: '',
          revealedRebusPositions: [],
        ),
      );

      return;
    }

    // =======================================================
    // LUCKY BOX
    // =======================================================

    if (gameMode == 'lucky' || gameMode == 'lucky_box') {
      sync.update(
        state.copyWith(
          gameMode: 'lucky',
          isLobby: false,
          questionIndex: 0,
          question: 'Chiếc hộp may mắn',
          clearImage: true,
          answers: [],
          clearCorrectAnswer: true,
          clearSelectedAnswer: true,
          selectedTeam: 0,
          showAnswer: false,
          scoreAwarded: false,
          finished: false,
          clearBonusTask: true,
          bonusUnlocked: false,
          bonusTaskResolved: false,
          bonusAwarded: false,
          bonusTaskCompleted: false,
          luckyBoxes: List<Map<String, dynamic>>.from(list),
          clearSelectedLuckyBox: true,
          clearOpenedLuckyBox: true,
          openedLuckyBoxIds: [],
          luckyRewardAwarded: false,
          luckyChallengeResolved: false,
          rebusAnswer: '',
          revealedRebusPositions: [],
        ),
      );
      return;
    }

    String question = '';
    String image = '';
    String rebusAnswer = '';
    List<String> answers = [];
    int? correctAnswer;

    image = item['image']?.toString() ?? '';

    if (gameMode == 'quiz') {
      question = item['question']?.toString() ?? '';

      answers = (item['answers'] as List? ?? [])
          .map((answer) => answer.toString())
          .toList();

      final rawAnswer = item['correctAnswer'];

      if (rawAnswer is int) {
        correctAnswer = rawAnswer >= 0 && rawAnswer < answers.length
            ? rawAnswer
            : null;
      } else {
        final answerIndex = answers.indexOf(
          rawAnswer?.toString() ?? '',
        );

        correctAnswer = answerIndex >= 0 ? answerIndex : null;
      }
    } else {
      switch (gameMode) {
        case 'rebus':
          question = item['hint']?.toString() ?? 'Hãy đoán hình!';
          rebusAnswer = item['answer']?.toString() ?? '';
          break;

        default:
          question = item['question']?.toString() ?? '';
      }
    }

    final task = gameMode == 'quiz'
        ? item['task']?.toString() ?? ''
        : '';

    final rawBonusPoints = item['bonusPoints'];

    final bonusPoints = rawBonusPoints is num
        ? rawBonusPoints.toInt()
        : 20;

    sync.update(
      state.copyWith(
        gameMode: gameMode,
        isLobby: false,
        questionIndex: index,
        question: question,
        image: image,
        answers: answers,
        correctAnswer: correctAnswer,
        clearCorrectAnswer: correctAnswer == null,
        clearSelectedAnswer: true,
        selectedTeam: 0,
        showAnswer: false,
        scoreAwarded: false,
        finished: false,
        bonusTask: task,
        bonusPoints: bonusPoints,
        bonusUnlocked: false,
        bonusTaskResolved: false,
        bonusAwarded: false,
        bonusTaskCompleted: false,

        // Rebus
        rebusAnswer: rebusAnswer,
        revealedRebusPositions: [],
      ),
    );
  }

  // =========================================================
  // CHỌN ĐỘI VÀ ĐÁP ÁN
  // =========================================================

  void _selectTeam(int index) {
    if (state.showAnswer || state.scoreAwarded) return;
    if (index < 0 || index >= state.teams.length) return;

    sync.update(
      state.copyWith(selectedTeam: index),
    );
  }

  void _selectAnswer(int index) {
    if (state.showAnswer || state.scoreAwarded) return;
    if (index < 0 || index >= state.answers.length) return;

    sync.update(
      state.copyWith(
        selectedAnswer: index,
        clearSelectedAnswer: false,
      ),
    );
  }

  // =========================================================
  // CÔNG BỐ ĐÁP ÁN VÀ TÍNH ĐIỂM QUIZ
  // =========================================================

  void _revealAnswer() {
    if (state.showAnswer || state.scoreAwarded) return;

    final selectedAnswer = state.selectedAnswer;
    final correctAnswer = state.correctAnswer;

    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hãy chọn đáp án của đội trước.'),
        ),
      );
      return;
    }

    if (state.questionIndex < 0 ||
        state.questionIndex >= _questions.length) {
      return;
    }

    final item = _questions[state.questionIndex];
    final scores = List<int>.from(state.scores);
    final teamIndex = state.selectedTeam;

    final isCorrect =
        correctAnswer != null && selectedAnswer == correctAnswer;

    if (isCorrect &&
        teamIndex >= 0 &&
        teamIndex < scores.length) {
      final rawPoints = item['points'];
      final points = rawPoints is num ? rawPoints.toInt() : 10;

      scores[teamIndex] += points;
    }

    final hasBonusTask =
        state.gameMode == 'quiz' && state.bonusTask.trim().isNotEmpty;

    sync.update(
      state.copyWith(
        scores: scores,
        showAnswer: true,
        scoreAwarded: true,
        bonusUnlocked: isCorrect && hasBonusTask,
      ),
    );
  }

  // =========================================================
  // XỬ LÝ BONUS
  // =========================================================

  void _resolveBonusTask({required bool completed}) {
    if (state.gameMode != 'quiz' ||
        state.bonusTask.trim().isEmpty ||
        !state.bonusUnlocked ||
        state.bonusTaskResolved ||
        !state.scoreAwarded) {
      return;
    }

    final scores = List<int>.from(state.scores);
    final teamIndex = state.selectedTeam;

    var awarded = false;

    if (completed &&
        !state.bonusAwarded &&
        teamIndex >= 0 &&
        teamIndex < scores.length) {
      scores[teamIndex] += state.bonusPoints;
      awarded = true;
    }

    sync.update(
      state.copyWith(
        scores: scores,
        bonusTaskResolved: true,
        bonusAwarded: awarded,
        bonusTaskCompleted: completed,
      ),
    );
  }

  // =========================================================
  // TÍNH ĐIỂM REBUS
  // =========================================================

  void _awardRebusPoints() {
    if (state.gameMode != 'rebus' ||
        state.scoreAwarded ||
        state.finished) {
      return;
    }

    if (state.selectedTeam < 0 ||
        state.selectedTeam >= state.scores.length) {
      return;
    }

    if (state.questionIndex < 0 ||
        state.questionIndex >= _questions.length) {
      return;
    }

    final item = _questions[state.questionIndex];
    final rawPoints = item['points'];
    final points = rawPoints is num ? rawPoints.toInt() : 10;

    final scores = List<int>.from(state.scores);
    scores[state.selectedTeam] += points;

    sync.update(
      state.copyWith(
        scores: scores,
        scoreAwarded: true,
        showAnswer: true,
      ),
    );
  }

  // =========================================================
  // CHUYỂN CÂU HỎI
  // =========================================================

  void _nextQuestion() {
    if (_questions.isEmpty) return;

    final nextIndex = state.questionIndex + 1;

    if (nextIndex >= _questions.length) {
      sync.update(
        state.copyWith(finished: true),
      );
      return;
    }

    _applyQuestion(nextIndex);
  }

  void _previousQuestion() {
    if (_questions.isEmpty || state.questionIndex <= 0) return;

    _applyQuestion(state.questionIndex - 1);
  }

  // =========================================================
  // ĐIỀU CHỈNH ĐIỂM
  // =========================================================

  void _changeScore(String team, int amount) {
    final teamIndex = state.teams.indexOf(team);

    if (teamIndex < 0 || teamIndex >= state.scores.length) return;

    final scores = List<int>.from(state.scores);
    scores[teamIndex] += amount;

    sync.update(
      state.copyWith(scores: scores),
    );
  }

  // =========================================================
  // QUAY VỀ SẢNH CHỜ
  // =========================================================

  void _returnToLobby() {
    sync.update(
      state.copyWith(
        isLobby: true,
        finished: false,
        questionIndex: 0,
        question: '',
        clearImage: true,
        answers: [],
        clearCorrectAnswer: true,
        clearSelectedAnswer: true,
        showAnswer: false,
        scoreAwarded: false,
        clearBonusTask: true,
        bonusUnlocked: false,
        bonusTaskResolved: false,
        bonusAwarded: false,
        bonusTaskCompleted: false,

        // Reset Lucky Box
        luckyBoxes: [],
        clearSelectedLuckyBox: true,
        clearOpenedLuckyBox: true,
        openedLuckyBoxIds: [],
        luckyRewardAwarded: false,
        luckyChallengeResolved: false,

        // Reset Rebus
        rebusAnswer: '',
        revealedRebusPositions: [],

        // Reset Crossword
        crosswordKeyword: '',
        crosswordRows: [],
        revealedCrosswordRows: [],
        clearSelectedCrosswordRow: true,
        crosswordKeywordRevealed: false,
        crosswordKeywordAwarded: false,
      ),
    );

    setState(() {
      _questions = [];
      _loadError = null;
    });
  }

  // =========================================================
  // RESET
  // =========================================================

  void _resetGame() {
    sync.reset();

    setState(() {
      _selectedMode = 'quiz';
      _questions = [];
      _loadError = null;
      _isLoading = false;
    });
  }

  // =========================================================
  // MỞ MÀN HÌNH DISPLAY
  // =========================================================

  void _openDisplay() {
    final uri = Uri.base.replace(
      queryParameters: {
        ...Uri.base.queryParameters,
        'mode': 'display',
      },
    );

    html.window.open(uri.toString(), 'mini_game_display');
  }

  // =========================================================
  // GIAO DIỆN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Game Show - Điều khiển'),
        actions: [
          IconButton(
            tooltip: 'Mở màn hình trình chiếu',
            onPressed: _openDisplay,
            icon: const Icon(Icons.tv),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: sync,
        builder: (context, _) {
          final hasQuestions = _questions.isNotEmpty &&
              state.questionIndex >= 0 &&
              state.questionIndex < _questions.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // CHỌN TRÒ CHƠI

              _sectionTitle('Chọn trò chơi'),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gameModes.entries.map((entry) {
                  final played = state.playedGames.contains(entry.key);

                  return ChoiceChip(
                    label: Text(
                      played ? '${entry.value} ✓' : entry.value,
                    ),
                    selected: _selectedMode == entry.key,
                    onSelected: played || _isLoading
                        ? null
                        : (_) => _selectMode(entry.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ||
                      state.playedGames.contains(_selectedMode)
                      ? null
                      : _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Bắt đầu trò chơi'),
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (_loadError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _loadError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const Divider(height: 32),

              // BẢNG ĐIỂM

              _sectionTitle('Bảng điểm'),

              const SizedBox(height: 12),

              HostScoreboard(
                teams: state.teams,
                scores: state.scores,
                onChangeScore: _changeScore,
              ),

              // KHU VỰC ĐIỀU KHIỂN

              if (!state.isLobby) ...[
                const Divider(height: 32),

                if (state.gameMode == 'lucky') ...[
                  _sectionTitle('Điều khiển Hộp may mắn'),

                  const SizedBox(height: 12),

                  if (state.finished)
                    Column(
                      children: [
                        const Text(
                          'Đã kết thúc Hộp may mắn!',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _returnToLobby,
                            icon: const Icon(Icons.home),
                            label: const Text('Về danh sách trò chơi'),
                          ),
                        ),
                      ],
                    )
                  else
                    LuckyBoxHost(sync: sync),
                ] else if (state.gameMode == 'crossword') ...[
                  _sectionTitle('Điều khiển Giải ô chữ'),

                  const SizedBox(height: 12),

                  if (state.finished)
                    Column(
                      children: [
                        const Text(
                          'Đã kết thúc Giải ô chữ!',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _returnToLobby,
                            icon: const Icon(Icons.home),
                            label: const Text('Về danh sách trò chơi'),
                          ),
                        ),
                      ],
                    )
                  else
                    CrosswordHost(sync: sync),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _sectionTitle('Câu hỏi'),
                      ),
                      if (_questions.isNotEmpty)
                        Text(
                          '${state.questionIndex + 1}/${_questions.length}',
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (hasQuestions) ...[
                    if (state.gameMode == 'quiz')
                      QuizHost(
                        state: state,
                        questionCount: _questions.length,
                        onSelectTeam: _selectTeam,
                        onSelectAnswer: _selectAnswer,
                        onRevealAnswer: _revealAnswer,
                        onResolveBonus: (completed) =>
                            _resolveBonusTask(completed: completed),
                        onPrevious: _previousQuestion,
                        onNext: _nextQuestion,
                        onReturnToLobby: _returnToLobby,
                      )
                    else ...[
                      HostQuestionCard(
                        question: state.question,
                        answers: state.answers,
                        selectedAnswer: state.selectedAnswer,
                        correctAnswer: state.correctAnswer,
                        showAnswer: state.showAnswer,
                        onSelectAnswer: _selectAnswer,
                      ),

                      // REBUS
                      if (state.gameMode == 'rebus') ...[
                        const SizedBox(height: 12),
                        RebusHost(
                          sync: sync,
                          onAwardCorrect: _awardRebusPoints,
                        ),
                      ],

                      const SizedBox(height: 12),

                      const Text(
                        'Đội trả lời',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.teams.asMap().entries.map((entry) {
                          return ChoiceChip(
                            label: Text(entry.value),
                            selected: state.selectedTeam == entry.key,
                            onSelected: state.scoreAwarded
                                ? null
                                : (_) => _selectTeam(entry.key),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: state.questionIndex > 0
                                  ? _previousQuestion
                                  : null,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Câu trước'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                              state.finished ? null : _nextQuestion,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(
                                state.questionIndex + 1 >= _questions.length
                                    ? 'Kết thúc'
                                    : 'Câu tiếp',
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (state.finished) ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Đã hết câu hỏi của trò chơi này!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _returnToLobby,
                            icon: const Icon(Icons.home),
                            label: const Text('Về danh sách trò chơi'),
                          ),
                        ),
                      ],
                    ],
                  ],
                ],
              ],

              // RESET

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: _resetGame,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Đặt lại trò chơi'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
