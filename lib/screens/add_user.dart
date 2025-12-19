import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_rolly/models/user.dart';
import 'package:frontend_rolly/models/user_response.dart';
import 'package:frontend_rolly/screens/add_role.dart';
import 'package:frontend_rolly/screens/admin_home_page.dart';
import 'package:frontend_rolly/screens/main_home_page.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../lang/app_language.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  late String? _birthdayError = null;
  late String? _usernameError = null;
  late String? _passwdError = null;
  late String? _emailError = null;
  late String? _roleError = null;

  String? _birthdayIso;
  String? selectedRole;

  bool _isLoading = false;

  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')!;
    
    final response = await http.get(
      Uri.parse(AppConfig.getAllRoles),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        _roles = data.map<String>((role) => role['name'] as String).toList();
      });
    }
  }

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

  Future<void> _addUser() async {
    setState(() => _isLoading = true);

    if (!isValidUsername(_usernameController.text)) {
      setState(() => _usernameError = context.read<AppLanguage>().t('wrongUsername'));
      return;
    } else {
        setState(() => _usernameError = null);
    }

    if (!isValidEmail(_emailController.text)) {
      setState(() => _emailError = context.read<AppLanguage>().t('wrongEmail'));
      return;
    } else {
        setState(() => _emailError = null);
    }

    if (!isValidPassword(_passwordController.text)) {
      setState(() => _passwdError = context.read<AppLanguage>().t('wrongPasswd'));
      return;
    } else {
        setState(() => _passwdError = null);
    }

    if (_birthdayController.text.isEmpty) {
      setState(() => _birthdayError = context.read<AppLanguage>().t('birthdayRequired'));
      return;
    } else {
      setState(() => _birthdayError = null);
    }

    UserDto u = UserDto(
      username: _usernameController.text, 
      email: _passwordController.text, 
      passwd: _passwordController.text,
      birthday: _birthdayIso!, 
      role: selectedRole!,
    );
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse(AppConfig.adminAaddlUser); 
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(u.toJson()),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {

        // Przejdź na ekran główny
        if (mounted) {
          final message = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
          );

          widget.onBack();
          Navigator.pop(context);
        }
    } else {
      // Obsługa błędów
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
  }

  Future<void> _addRole() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRole(onBack: (){}, onRefresh: () async { await _fetchRoles(); },)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.text,
            onPressed: () {
              widget.onBack();
              Navigator.pop(context);
            },
          ),
        title: Text(lang.t('addUser'), style: TextStyle(color: AppColors.text)),
        
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Pole użytkownika
              Text(
                lang.t('username'),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _usernameError,
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
              const SizedBox(height: 24),

              // Pole hasła
              Text(
                lang.t('password'),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _passwdError,
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
              const SizedBox(height: 24),

              // Pole email
              Text(
                lang.t('email'),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _emailError,
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
              const SizedBox(height: 24),

              // Pole birthday
              Text(
                lang.t('birthday'),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    controller: _birthdayController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _birthdayError,
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
                            _birthdayController.text = 
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

              // Pole role
              Text(
                lang.t('role'),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: lang.t('role'),
                      filled: true,
                      fillColor: AppColors.accent,
                      errorText: _roleError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    items: _roles.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                        _roleError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('or'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Przycisk dodawania
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
                            onPressed: _addRole,
                            child: Text(
                              lang.t('addNewRole'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                    ),
              const SizedBox(height: 48),

              // Przycisk logowania
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
                        onPressed: _addUser,
                        child: Text(
                          lang.t('addUser'),
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
        ),
      ),
    );
  }
}
