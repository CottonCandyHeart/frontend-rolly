import 'package:frontend_rolly/models/route_photo.dart';
import 'package:frontend_rolly/models/route_point.dart';

class TrainingRoute {
  final String name;
  final double distance;
  final int estimatedTime;
  final DateTime date;
  final List<RoutePoint> points;
  final List<RoutePhoto> photos;
  final int caloriesBurned;

  TrainingRoute({
    required this.name, required this.distance, required this.estimatedTime, required this.date, 
    required this.points, required this.photos, required this.caloriesBurned,
  });

  factory TrainingRoute.fromJson(Map<String, dynamic> json) {
    return TrainingRoute(
      name: json['name'],
      distance: json['distance'],
      estimatedTime: json['estimatedTime'],
      date: DateTime.parse(json['date']),
      points: (json['points'] as List).map((p) => RoutePoint.fromJson(p)).toList(),
      photos: (json['photos'] as List).map((p) => RoutePhoto.fromJson(p)).toList(),
      caloriesBurned: json['caloriesBurned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'date': date.toIso8601String(),
      'points': points.map((p) => p.toJson()).toList(),
      'photos': photos.map((p) => p.toJson()).toList(),
      'caloriesBurned': caloriesBurned,
    };
  }
}