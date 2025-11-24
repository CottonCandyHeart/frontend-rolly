import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/models/user_response.dart';
import 'package:frontend_rolly/services/user_service.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lang/app_language.dart';

class ChangePasswdWidget extends StatefulWidget {
  const ChangePasswdWidget({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ChangePasswdWidget> createState() => _ChangePasswdState();
}

class _ChangePasswdState extends State<ChangePasswdWidget> {
  String? token;
  final TextEditingController _emailController = TextEditingController();
  late Future<UserResponse>? userResponse;

  bool _isLoading = false;

  String? _emailError;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('jwt_token');

    setState(() {
      token = storedToken;
      if (token != null) {
        userResponse = UserService().getProfile(token!);
      }
    });
  }

  bool isValidEmail(String email) {
    // (a-z, A-Z), (0-9), (underscore), (minus), (dot)
    // @
    // co najmniej jeden segment domeny np. gmail. lub my-company.
    // końcówka, min. 2 znaki
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  Future<void> _setEmail() async {
    setState(() => _isLoading = true);
    if (!isValidEmail(_emailController.text)) {
      setState(() => _emailError = context.read<AppLanguage>().t('wrongEmail'));
      return;
    } else {
        setState(() => _emailError = null);
    }

    final url = Uri.parse(AppConfig.userResponse); 
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'email': _emailController.text,
        'role': 'user',
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final message = response.body;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
        setState(() {
          userResponse = UserService().getProfile(token!);
          _emailController.text = "";
          widget.onBack();
        });                                                                          
      }
    } else {
      // Obsługa błędów
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('wrongEmail'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguage>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
                lang.t('oldEmail'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                child: FutureBuilder<UserResponse>(
                  future: userResponse, 
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(lang.t('loading'), style: TextStyle(color: AppColors.text));
                    }

                    if (snapshot.hasError) {
                      return Text(lang.t('loadingProfileFailed'), style: TextStyle(color: AppColors.text));
                    }

                    final data = snapshot.data!;

                    return Center(
                      child: Text(
                        data.email,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.text,
                        ),
                      ),
                    );
                  }
                )
              ),
              
              const SizedBox(height: 36),
              Text(
                lang.t('newEmail'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 48,
                  ),
                  child: TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _emailError,
                      filled: true,
                      fillColor: AppColors.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

          const SizedBox(height: 20),
          SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _setEmail,
                        child: Text(
                          lang.t('update'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.background,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
        ],
      ),
    );
  }

}
