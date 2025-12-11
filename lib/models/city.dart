class City {
  final int id;
  final String city;

  City({
    required this.id, required this.city,
  });

  factory City.fromJson(Map<String, dynamic> json) {

    return City(
      id: json['id'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'city': city,
    };
  }
}