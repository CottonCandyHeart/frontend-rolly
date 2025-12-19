class UserDto {
    final String username;
    final String email;
    final String passwd;
    final String birthday;  // YY - mm - dd
    final String role;

  UserDto({
    required this.username, 
    required this.email, 
    required this.passwd,
    required this.birthday, 
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'passwd': passwd,
      'birthday': birthday,
      'role': role,
    };
  }

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      username: json['username'],
      email: json['email'],
      passwd: json['passwd'],
      birthday: json['birthday'],
      role: json['role'],
    );
  }
}
