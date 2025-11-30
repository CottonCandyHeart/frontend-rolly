class RoutePhoto {
  final int id;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final DateTime timestamp;

  RoutePhoto({
    required this.id, required this.latitude, required this.longitude, required this.imageUrl, required this.timestamp
  });

  factory RoutePhoto.fromJson(Map<String, dynamic> json) {
    return RoutePhoto(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrl: json['imageUrl'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }
}
