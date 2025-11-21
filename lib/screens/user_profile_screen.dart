

import 'package:flutter/material.dart';
import 'package:frontend_rolly/models/user_response.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userResponse});

  final UserResponse userResponse;

  @override
  State<UserProfileScreen> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}