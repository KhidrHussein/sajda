class Streak {
  final int? id;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastUpdated;

  Streak({
    this.id,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastUpdated,
  });

  Streak copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastUpdated,
  }) {
    return Streak(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      id: map['id'],
      currentStreak: map['current_streak'],
      longestStreak: map['longest_streak'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
}
