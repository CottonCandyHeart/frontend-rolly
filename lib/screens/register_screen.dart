import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_rolly/screens/get_measurements_screen.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import '../lang/app_language.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  
  String? _emailError;
  String? _passwdMatchError;
  String? _passwdError;
  String? _userError;
  String? _birthDateError;

  String? _birthdayIso;

  bool _isLoading = false;

  bool isValidUsername(String username) {
    //min. 3 znaki, litery i cyfry, bez spacji
    final regex = RegExp(r"^[a-zA-Z0-9_]{3,20}$");
    return regex.hasMatch(username);
  }

  bool isValidEmail(String email) {
    // (a-z, A-Z), (0-9), (underscore), (minus), (dot)
    // @
    // co najmniej jeden segment domeny np. gmail. lub my-company.
    // końcówka, min. 2 znaki
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    // min. 8 znaków, duża litera, mała litera, cyfra, znak specjalny
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._-])[A-Za-z\d@$!%*?&._-]{8,}$'
    );
    return regex.hasMatch(password);
  }

  Future<void> _register() async {
    if (!isValidUsername(_usernameController.text)) {
      setState(() => _userError = context.read<AppLanguage>().t('wrongUsername'));
      return;
    } else {
        setState(() => _userError = null);
    }

    if (!isValidEmail(_emailController.text)) {
      setState(() => _emailError = context.read<AppLanguage>().t('wrongEmail'));
      return;
    } else {
        setState(() => _emailError = null);
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _passwdMatchError = context.read<AppLanguage>().t('differentPasswd'));
      return;
    } else {
        setState(() => _passwdMatchError = null);
    }

    if (!isValidPassword(_passwordController.text)) {
      setState(() => _passwdError = context.read<AppLanguage>().t('wrongPasswd'));
      return;
    } else {
        setState(() => _passwdError = null);
    }

    if (_birthDateController.text.isEmpty) {
      setState(() => _birthDateError = context.read<AppLanguage>().t('birthdayRequired'));
      return;
    } else {
      setState(() => _birthDateError = null);
    }

    setState(() => _isLoading = true);

  final url = Uri.parse(AppConfig.registerEndpoint); 
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'username': _usernameController.text,
      'email': _emailController.text,
      'passwd': _passwordController.text,
      'birthday': _birthdayIso,
      'role': 'user'
    }),
  );

  if (response.statusCode == 200) {
    // automatyczne logowanie po rejestracji
    final loginUrl = Uri.parse(AppConfig.loginEndpoint);
    final loginResponse = await http.post(
      loginUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'passwd': _passwordController.text,
      }),
    );

    print('Login response status: ${loginResponse.statusCode}');
    print('Login response body: ${loginResponse.body}');

    setState(() => _isLoading = false);

    if (loginResponse.statusCode == 200) {
      final data = json.decode(loginResponse.body);
      final token = data['token'];

      if (token != null) {
        // zapisz token lokalnie
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        // przejdź do ekranu wymiarów z tokenem
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GetMeasurementsScreen(),
            ),
          );
        }
      }
    } else {
      // obsługa błędu logowania
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('loginFailed'))),
      );
    }
  } else {
    setState(() => _isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.read<AppLanguage>().t('userExists'))),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo zamiast kółka
              SvgPicture.asset(
                AppConfig.logoImg,
                height: 80,
              ),
              const SizedBox(height: 16),

              Text(
                'Rolly',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                lang.t('createNewAccount'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 24),

              // Pole użytkownika
              TextField(
                controller: _usernameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _userError,
                  errorMaxLines: 3,
                  hintText: lang.t('username'),
                  hintStyle: TextStyle(
                    color: AppColors.text,
                  ),
                  filled: true,
                  fillColor: AppColors.accent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pole email
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _emailError,
                  errorMaxLines: 3,
                  hintText: lang.t('email'),
                  hintStyle: TextStyle(
                    color: AppColors.text,
                  ),
                  filled: true,
                  fillColor: AppColors.accent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pole hasła
              TextField(
                controller: _passwordController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _passwdError,
                  errorMaxLines: 3,
                  hintText: lang.t('password'),
                  hintStyle: TextStyle(
                    color: AppColors.text,
                  ),
                  filled: true,
                  fillColor: AppColors.accent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Powtórz hasło
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _passwdMatchError,
                  errorMaxLines: 3,
                  hintText: lang.t('confPasswd'),
                  hintStyle: TextStyle(
                    color: AppColors.text,
                  ),
                  filled: true,
                  fillColor: AppColors.accent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Urodziny
              Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    controller: _birthDateController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _birthDateError,
                      errorMaxLines: 3,
                      hintText: lang.t('birthday'),
                      hintStyle: TextStyle(
                        color: AppColors.text,
                      ),
                      filled: true,
                      fillColor: AppColors.accent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: AppColors.background,
                                onSurface: AppColors.text,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                          setState(() {
                            _birthDateController.text = 
                              "${picked.day.toString().padLeft(2,'0')}.${picked.month.toString().padLeft(2,'0')}.${picked.year}";
                            _birthdayIso =
                              "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
                          });
                      }
                    },
                  ),

                  Positioned(
                    right: 18,
                    child: GestureDetector(
                      onTap: () async {},
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Przycisk rejestracji
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
                        onPressed: _register,
                        child: Text(
                          lang.t('signup'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.background,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(
                  lang.t('goToLogin'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  