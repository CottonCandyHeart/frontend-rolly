import 'dart:convert';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/models/user_response.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<UserResponse> getProfile(String? token) async {
    if (token == null || token.isEmpty) {
      throw Exception("Token is null or empty");
    }

    final response = await http.get(
      Uri.parse(AppConfig.userResponse),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      }
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load profile: ${response.statusCode}");
    }
  }
}