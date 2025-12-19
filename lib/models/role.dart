class Role {
    final int id;
    final String name;
    final String description;

  Role({
    required this.id, 
    required this.name, 
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}