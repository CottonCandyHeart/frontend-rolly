import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/screens/admin_home_page.dart';
import 'package:frontend_rolly/screens/main_home_page.dart';
import 'package:frontend_rolly/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    loadAndScheduleNotifications();
  }

  Future<void> checkAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse(AppConfig.chackAdminRole); 
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage(title: 'Rolly')),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Rolly')),
      );
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    await Future.delayed(const Duration(seconds: 1));

    if (token != null && token.isNotEmpty) {
      if (!mounted) return;

      await checkAdmin();
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> loadAndScheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) return;

    final backendNotifications =
        await fetchNotifications(token);

    await syncNotificationsFromBackend(backendNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppConfig.logoLightImg,
              width: 250, 
              height: 250,
            ),
          ],
        ),
      ),
    );
  }
}
