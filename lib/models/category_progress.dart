class CategoryProgress {
  final String name;
  final int total;
  final int mastered;

  CategoryProgress({
    required this.name,
    required this.total,
    required this.mastered,
  });

  double get progress =>
      total == 0 ? 0 : mastered / total;

  factory CategoryProgress.fromJson(Map<String, dynamic> json) {
    return CategoryProgress(
      name: json['categoryName'],
      total: json['totalTricks'],
      mastered: json['masteredTricks'],
    );
  }
}
