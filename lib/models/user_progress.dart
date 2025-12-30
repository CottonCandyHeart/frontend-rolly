class UserProgress {
  final int id;
  final double totalDistance;
  final int totalSessions;
  final int totalTricksLearned;
  final int caloriesBurned;
  final DateTime lastUpdated;
  final String username;

  UserProgress({
    required this.id,
    required this.totalDistance,
    required this.totalSessions,
    required this.totalTricksLearned,
    required this.caloriesBurned,
    required this.lastUpdated,
    required this.username
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'],
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalSessions: json['totalSessions'],
      totalTricksLearned: json['totalTricksLearned'],
      caloriesBurned: json['caloriesBurned'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      username: json['username']
    );
  }
}