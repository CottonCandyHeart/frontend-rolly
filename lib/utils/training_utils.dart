import 'package:frontend_rolly/models/training_plan.dart';

class TrainingUtils {
  static Future<List<int>> extractTrainingDays(Future<List<TrainingPlan>> trainingsFuture) async {
    final trainings = await trainingsFuture;

    return trainings
        .map((t) => t.dateTime.day)
        .toSet()
        .toList()
      ..sort();
  }
}
