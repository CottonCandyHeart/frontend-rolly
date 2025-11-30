class TrainingPlan {
  final int id;
  final DateTime dateTime;
  final int targetDuration;
  final String notes;
  bool completed;

  TrainingPlan({
    required this.id, required this.dateTime, required this.targetDuration,
    required this.notes, required this.completed
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'],
      dateTime: json['dateTime'],
      targetDuration: json['targetDuration'],
      notes: json['notes'],
      completed: json['completed']
    );
  }
}
