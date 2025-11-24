class Measurements {
    final double weight;
    final int height;

  Measurements({
    required this.weight, 
    required this.height
  });

  factory Measurements.fromJson(Map<String, dynamic> json) {
    return Measurements(
      weight: json['weight'],
      height: json['height']
    );
  }
}
