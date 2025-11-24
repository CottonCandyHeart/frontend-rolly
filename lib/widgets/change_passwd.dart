
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeEmailWidget extends StatefulWidget {
  const ChangeEmailWidget({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ChangeEmailWidget> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmailWidget> {
 String? token;
  final TextEditingController _oldPasswdController = TextEditingController();
  final TextEditingController _newPasswdController = TextEditingController();
  final TextEditingController _confirmPasswdController = TextEditingController();

  bool _isLoading = false;

  String? _passwdMatchError;
  String? _samePasswdError;
  String? _passwdError;

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
    });
  }

  bool isValidPassword(String password) {
    // min. 8 znaków, duża litera, mała litera, cyfra, znak specjalny
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._-])[A-Za-z\d@$!%*?&._-]{8,}$'
    );
    return regex.hasMatch(password);
  }

  Future<void> _changePasswd() async {
    setState(() => _isLoading = true);

    if (_newPasswdController.text == _oldPasswdController.text) {
      setState(() => _samePasswdError = context.read<AppLanguage>().t('passwordsAreTheSame'));
      return;
    } else {
        setState(() => _samePasswdError = null);
    }

    if (_newPasswdController.text != _confirmPasswdController.text) {
      setState(() => _passwdMatchError = context.read<AppLanguage>().t('differentPasswd'));
      return;
    } else {
        setState(() => _passwdMatchError = null);
    }

    if (!isValidPassword(_newPasswdController.text)) {
      setState(() => _passwdError = context.read<AppLanguage>().t('wrongPasswd'));
      return;
    } else {
        setState(() => _passwdError = null);
    }

    final url = Uri.parse(AppConfig.changePasswd); 
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'currentPasswd': _oldPasswdController.text,
        'newPasswd': _newPasswdController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final message = response.body;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
        setState(() {});
        _oldPasswdController.text = "";
        _newPasswdController.text = "";
        _confirmPasswdController.text = "";
        widget.onBack();
      }

    } else {
      // Obsługa błędów
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('failedChangingPasswd'))),
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
                lang.t('oldPasswd'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 48,
                  ),
                  child: TextField(
                    controller: _oldPasswdController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _samePasswdError,
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: AppColors.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Text(
                lang.t('newPasswd'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 48,
                  ),
                  child: TextField(
                    controller: _newPasswdController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _passwdError,
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: AppColors.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
          ),  

          const SizedBox(height: 24),
          Text(
                lang.t('confirmPasswd'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 48,
                  ),
                  child: TextField(
                    controller: _confirmPasswdController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _passwdMatchError,
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: AppColors.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
        
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
                        onPressed: _changePasswd,
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
