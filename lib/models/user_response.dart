class UserResponse {
    final String username;
    final String email;
    final String birthday;  // YY - mm - dd
    final String role;
    final String level;

  UserResponse({
    required this.username, 
    required this.email, 
    required this.birthday, 
    required this.role,
    required this.level 
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      username: json['username'],
      email: json['email'],
      birthday: json['birthday'],
      role: json['role'],
      level: json['level']
    );
  }
}
