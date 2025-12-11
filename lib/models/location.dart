class Location {
  final int id;
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.id, required this.name, required this.city, required this.country, required this.latitude, required this.longitude
  });

  factory Location.fromJson(Map<String, dynamic> json) {

    return Location(
      id: json['id'] as int,
      name: json['name'],
      city: json['city'],
      country: json['country'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}