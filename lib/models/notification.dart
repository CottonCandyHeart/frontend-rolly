class CustomNotification {
  final int id;
  final String title;
  final String message;
  final DateTime sentAt;
  bool read;

  CustomNotification({
    required this.id, required this.title, required this.message, required this.sentAt, required this.read, 
  });

  factory CustomNotification.fromJson(Map<String, dynamic> json) {
    return CustomNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      sentAt: DateTime.parse(json['sentAt']),
      read: json['read'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'read': read,
    };
  }
}
