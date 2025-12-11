class Meeting {
  final String name;
  final String description;
  final String organizerUsername;
  final DateTime dateTime;
  final String level;
  final String type;
  final String age;
  final int numberOfParticipants;
  final String locationName;
  final String action;

  Meeting({
    required this.name, required this.description, required this.organizerUsername, required this.dateTime, required this.level, 
    required this.type, required this.age, required this.numberOfParticipants, required this.locationName, required this.action
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    final dateParts = (json['date'] as String).split('-');
    final timeParts = (json['time'] as String).split(':');

    final dateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final String name = (json['name'] as String?) ?? 'Unknown';
    final String description = (json['description'] as String?) ?? 'No Description';
    final String organizerUsername = (json['organizerUsername'] as String?) ?? 'Unknown';
    final String level = (json['level'] as String?) ?? 'Unknown';
    final String type = (json['type'] as String?) ?? 'Other';
    final String age = (json['age'] as String?) ?? '0-100';
    final int numberOfParticipants = (json['numberOfParticipants'] as int?) ?? 1; 
    final String locationName = (json['locationName'] as String?) ?? 'Unknown Location';
    final String action = (json['action'] as String?) ?? 'view';

    return Meeting(
      name: name,
      description: description,
      organizerUsername: organizerUsername,
      dateTime: dateTime,
      level: level,
      type: type,
      age: age,
      numberOfParticipants: numberOfParticipants,
      locationName: locationName,
      action: action,
    );
  }

  Map<String, dynamic> toJson() {
    final date = "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    final time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

    return {
      'name': name,
      'description': description,
      'organizerUsername': organizerUsername,
      'date': date,
      'time': time,
      'level': level,
      'type': type,
      'age': age,
      'numberOfParticipants': numberOfParticipants,
      'locationName': locationName,
      'action': action
    };
  }
}