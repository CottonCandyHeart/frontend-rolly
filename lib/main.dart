import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend_rolly/services/notification_service.dart';
import 'theme/colors.dart';
import 'package:provider/provider.dart';
import 'lang/app_language.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications();

  await notifications
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();

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
