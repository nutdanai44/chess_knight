class LeaderboardEntry {
  final String name;
  final String cellSize;
  final String timeTaken; // Time taken to complete
  final int backCount; // Number of back actions used
  final double score; // Calculated score

  LeaderboardEntry({
    required this.name,
    required this.cellSize,
    required this.timeTaken,
    required this.backCount,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cellSize': cellSize,
      'timeTaken': timeTaken,
      'backCount': backCount,
      'score': score,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      name: map['name'],
      cellSize: map['cellSize'],
      timeTaken: map['timeTaken'],
      backCount: map['backCount'],
      score: map['score'],
    );
  }
}