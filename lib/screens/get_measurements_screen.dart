import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../lang/app_language.dart';
import 'package:provider/provider.dart';
import 'main_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetMeasurementsScreen extends StatefulWidget {
  const GetMeasurementsScreen({super.key});

  @override
  State<GetMeasurementsScreen> createState() => _GetMeasurementsState();
}

class _GetMeasurementsState extends State<GetMeasurementsScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String? _heightError;
  String? _weightError;

  bool _isLoading = false;


  Future<void> _register() async {
    
    setState(() => _isLoading = true);

    // Pobierz token z pamięci
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse(AppConfig.measurementsEndpoint); 
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'weight': double.parse(_weightController.text),
        'height': int.parse(_heightController.text)
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
        // Przejdź do logowania
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage(title: AppConfig.appName)),
          );
        }
    } else {
      // Obsługa błędów
      if (!mounted) return;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppConfig.logoImg,
                height: 160,
              ),
              const SizedBox(height: 16),

              Text(
                lang.t('appName'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                lang.t('shareMeasurements'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 24),

              // Waga (kg)
              TextField(
                controller: _weightController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _weightError,
                  errorMaxLines: 3,
                  hintText: lang.t('weight'),
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

              // Wzrost (cm)
              TextField(
                controller: _heightController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _heightError,
                  errorMaxLines: 3,
                  hintText: lang.t('height'),
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

              // Przycisk kontynuacji
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
                          lang.t('continue'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.background,
                          ),
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
