
class GameState {
  final String gameMode;
  final bool isLobby;
  final List<String> playedGames;

  final int questionIndex;
  final List<String> teams;
  final List<int> scores;
  final int selectedTeam;
  final String question;
  final String image;
  final List<String> answers;
  final int? correctAnswer;
  final int? selectedAnswer;
  final bool showAnswer;
  final bool scoreAwarded;
  final bool finished;

  final String bonusTask;
  final int bonusPoints;
  final bool bonusUnlocked;
  final bool bonusTaskResolved;
  final bool bonusAwarded;
  final bool bonusTaskCompleted;

  // Lucky Box
  final List<Map<String, dynamic>> luckyBoxes;
  final int? selectedLuckyBoxId;
  final int? openedLuckyBoxId;
  final List<int> openedLuckyBoxIds;
  final bool luckyRewardAwarded;
  final bool luckyChallengeResolved;

  // Rebus
  final String rebusAnswer;
  final List<int> revealedRebusPositions;

  // Crossword
  final String crosswordKeyword;
  final List<Map<String, dynamic>> crosswordRows;
  final List<int> revealedCrosswordRows;
  final int? selectedCrosswordRow;
  final bool crosswordKeywordRevealed;
  final bool crosswordKeywordAwarded;

  const GameState({
    this.gameMode = 'quiz',
    this.isLobby = true,
    this.playedGames = const [],
    this.questionIndex = 0,
    this.teams = const ['Đội Mây Xanh', 'Đội Mặt Trời'],
    this.scores = const [0, 0],
    this.selectedTeam = 0,
    this.question = '',
    this.image = '',
    this.answers = const [],
    this.correctAnswer,
    this.selectedAnswer,
    this.showAnswer = false,
    this.scoreAwarded = false,
    this.finished = false,
    this.bonusTask = '',
    this.bonusPoints = 20,
    this.bonusUnlocked = false,
    this.bonusTaskResolved = false,
    this.bonusAwarded = false,
    this.bonusTaskCompleted = false,

    // Lucky Box
    this.luckyBoxes = const [],
    this.selectedLuckyBoxId,
    this.openedLuckyBoxId,
    this.openedLuckyBoxIds = const [],
    this.luckyRewardAwarded = false,
    this.luckyChallengeResolved = false,

    // Rebus
    this.rebusAnswer = '',
    this.revealedRebusPositions = const [],

    // Crossword
    this.crosswordKeyword = '',
    this.crosswordRows = const [],
    this.revealedCrosswordRows = const [],
    this.selectedCrosswordRow,
    this.crosswordKeywordRevealed = false,
    this.crosswordKeywordAwarded = false,
  });

  GameState copyWith({
    String? gameMode,
    bool? isLobby,
    List<String>? playedGames,
    int? questionIndex,
    List<String>? teams,
    List<int>? scores,
    int? selectedTeam,
    String? question,
    String? image,
    bool clearImage = false,
    List<String>? answers,
    int? correctAnswer,
    bool clearCorrectAnswer = false,
    int? selectedAnswer,
    bool clearSelectedAnswer = false,
    bool? showAnswer,
    bool? scoreAwarded,
    bool? finished,
    String? bonusTask,
    bool clearBonusTask = false,
    int? bonusPoints,
    bool? bonusUnlocked,
    bool? bonusTaskResolved,
    bool? bonusAwarded,
    bool? bonusTaskCompleted,

    // Lucky Box
    List<Map<String, dynamic>>? luckyBoxes,
    int? selectedLuckyBoxId,
    bool clearSelectedLuckyBox = false,
    int? openedLuckyBoxId,
    bool clearOpenedLuckyBox = false,
    List<int>? openedLuckyBoxIds,
    bool? luckyRewardAwarded,
    bool? luckyChallengeResolved,

    // Rebus
    String? rebusAnswer,
    List<int>? revealedRebusPositions,

    // Crossword
    String? crosswordKeyword,
    List<Map<String, dynamic>>? crosswordRows,
    List<int>? revealedCrosswordRows,
    int? selectedCrosswordRow,
    bool clearSelectedCrosswordRow = false,
    bool? crosswordKeywordRevealed,
    bool? crosswordKeywordAwarded,
  }) {
    return GameState(
      gameMode: gameMode ?? this.gameMode,
      isLobby: isLobby ?? this.isLobby,
      playedGames: playedGames ?? this.playedGames,
      questionIndex: questionIndex ?? this.questionIndex,
      teams: teams ?? this.teams,
      scores: scores ?? this.scores,
      selectedTeam: selectedTeam ?? this.selectedTeam,
      question: question ?? this.question,
      image: clearImage ? '' : (image ?? this.image),
      answers: answers ?? this.answers,
      correctAnswer: clearCorrectAnswer
          ? null
          : (correctAnswer ?? this.correctAnswer),
      selectedAnswer: clearSelectedAnswer
          ? null
          : (selectedAnswer ?? this.selectedAnswer),
      showAnswer: showAnswer ?? this.showAnswer,
      scoreAwarded: scoreAwarded ?? this.scoreAwarded,
      finished: finished ?? this.finished,
      bonusTask: clearBonusTask ? '' : (bonusTask ?? this.bonusTask),
      bonusPoints: bonusPoints ?? this.bonusPoints,
      bonusUnlocked: bonusUnlocked ?? this.bonusUnlocked,
      bonusTaskResolved: bonusTaskResolved ?? this.bonusTaskResolved,
      bonusAwarded: bonusAwarded ?? this.bonusAwarded,
      bonusTaskCompleted: bonusTaskCompleted ?? this.bonusTaskCompleted,

      // Lucky Box
      luckyBoxes: luckyBoxes ?? this.luckyBoxes,
      selectedLuckyBoxId: clearSelectedLuckyBox
          ? null
          : (selectedLuckyBoxId ?? this.selectedLuckyBoxId),
      openedLuckyBoxId: clearOpenedLuckyBox
          ? null
          : (openedLuckyBoxId ?? this.openedLuckyBoxId),
      openedLuckyBoxIds: openedLuckyBoxIds ?? this.openedLuckyBoxIds,
      luckyRewardAwarded:
      luckyRewardAwarded ?? this.luckyRewardAwarded,
      luckyChallengeResolved:
      luckyChallengeResolved ?? this.luckyChallengeResolved,

      // Rebus
      rebusAnswer: rebusAnswer ?? this.rebusAnswer,
      revealedRebusPositions:
      revealedRebusPositions ?? this.revealedRebusPositions,

      // Crossword
      crosswordKeyword: crosswordKeyword ?? this.crosswordKeyword,
      crosswordRows: crosswordRows ?? this.crosswordRows,
      revealedCrosswordRows:
      revealedCrosswordRows ?? this.revealedCrosswordRows,
      selectedCrosswordRow: clearSelectedCrosswordRow
          ? null
          : (selectedCrosswordRow ?? this.selectedCrosswordRow),
      crosswordKeywordRevealed:
      crosswordKeywordRevealed ?? this.crosswordKeywordRevealed,
      crosswordKeywordAwarded:
      crosswordKeywordAwarded ?? this.crosswordKeywordAwarded,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameMode': gameMode,
    'isLobby': isLobby,
    'playedGames': playedGames,
    'questionIndex': questionIndex,
    'teams': teams,
    'scores': scores,
    'selectedTeam': selectedTeam,
    'question': question,
    'image': image,
    'answers': answers,
    'correctAnswer': correctAnswer,
    'selectedAnswer': selectedAnswer,
    'showAnswer': showAnswer,
    'scoreAwarded': scoreAwarded,
    'finished': finished,
    'bonusTask': bonusTask,
    'bonusPoints': bonusPoints,
    'bonusUnlocked': bonusUnlocked,
    'bonusTaskResolved': bonusTaskResolved,
    'bonusAwarded': bonusAwarded,
    'bonusTaskCompleted': bonusTaskCompleted,

    // Lucky Box
    'luckyBoxes': luckyBoxes,
    'selectedLuckyBoxId': selectedLuckyBoxId,
    'openedLuckyBoxId': openedLuckyBoxId,
    'openedLuckyBoxIds': openedLuckyBoxIds,
    'luckyRewardAwarded': luckyRewardAwarded,
    'luckyChallengeResolved': luckyChallengeResolved,

    // Rebus
    'rebusAnswer': rebusAnswer,
    'revealedRebusPositions': revealedRebusPositions,

    // Crossword
    'crosswordKeyword': crosswordKeyword,
    'crosswordRows': crosswordRows,
    'revealedCrosswordRows': revealedCrosswordRows,
    'selectedCrosswordRow': selectedCrosswordRow,
    'crosswordKeywordRevealed': crosswordKeywordRevealed,
    'crosswordKeywordAwarded': crosswordKeywordAwarded,
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      gameMode: json['gameMode'] as String? ?? 'quiz',
      isLobby: json['isLobby'] as bool? ?? true,
      playedGames: List<String>.from(json['playedGames'] ?? []),
      questionIndex: json['questionIndex'] as int? ?? 0,
      teams: List<String>.from(
        json['teams'] ?? ['Đội Mây Xanh', 'Đội Mặt Trời'],
      ),
      scores: List<int>.from(json['scores'] ?? [0, 0]),
      selectedTeam: json['selectedTeam'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      image: json['image'] as String? ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      correctAnswer: json['correctAnswer'] as int?,
      selectedAnswer: json['selectedAnswer'] as int?,
      showAnswer: json['showAnswer'] as bool? ?? false,
      scoreAwarded: json['scoreAwarded'] as bool? ?? false,
      finished: json['finished'] as bool? ?? false,
      bonusTask: json['bonusTask'] as String? ?? '',
      bonusPoints: json['bonusPoints'] as int? ?? 20,
      bonusUnlocked: json['bonusUnlocked'] as bool? ?? false,
      bonusTaskResolved: json['bonusTaskResolved'] as bool? ?? false,
      bonusAwarded: json['bonusAwarded'] as bool? ?? false,
      bonusTaskCompleted: json['bonusTaskCompleted'] as bool? ?? false,

      // Lucky Box
      luckyBoxes: (json['luckyBoxes'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          const [],
      selectedLuckyBoxId: json['selectedLuckyBoxId'] as int?,
      openedLuckyBoxId: json['openedLuckyBoxId'] as int?,
      openedLuckyBoxIds: List<int>.from(
        json['openedLuckyBoxIds'] ?? [],
      ),
      luckyRewardAwarded:
      json['luckyRewardAwarded'] as bool? ?? false,
      luckyChallengeResolved:
      json['luckyChallengeResolved'] as bool? ?? false,

      // Rebus
      rebusAnswer: json['rebusAnswer'] as String? ?? '',
      revealedRebusPositions: List<int>.from(
        json['revealedRebusPositions'] ?? [],
      ),

      // Crossword
      crosswordKeyword: json['crosswordKeyword'] as String? ?? '',
      crosswordRows: (json['crosswordRows'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          const [],
      revealedCrosswordRows: List<int>.from(
        json['revealedCrosswordRows'] ?? [],
      ),
      selectedCrosswordRow: json['selectedCrosswordRow'] as int?,
      crosswordKeywordRevealed:
      json['crosswordKeywordRevealed'] as bool? ?? false,
      crosswordKeywordAwarded:
      json['crosswordKeywordAwarded'] as bool? ?? false,
    );
  }
}
