import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'package:provider/provider.dart';
import 'lang/app_language.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppLanguage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguage>();

    return MaterialApp(
      title: 'Rolly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
        fontFamily: 'Poppins',
      ),
      
      home: const SplashScreen(),
    );
  }
}
