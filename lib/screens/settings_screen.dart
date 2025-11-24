import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/user_response.dart';
import 'package:frontend_rolly/screens/chosen_settings_screen.dart';
import 'package:frontend_rolly/screens/login_screen.dart';
import 'package:frontend_rolly/screens/user_profile_screen.dart';
import 'package:frontend_rolly/services/user_service.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? token;
  late Future<UserResponse> userResponse;

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

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) widget.onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.text,
            onPressed: () {
              widget.onBack();
              Navigator.pop(context);
            },
          ),
          title: Text(lang.t('settings'), style: TextStyle(color: AppColors.text)),
        ),
        body: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(color: AppColors.primary),
                    padding: const EdgeInsets.all(2),
                    width: MediaQuery.of(context).size.width * 0.2,
                    margin: const EdgeInsets.only(top: 20),
                    child: const Center(
                      child: Icon(
                        Icons.person_2_outlined,
                        color: AppColors.background,
                        size: 60,
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.4,
                    margin: const EdgeInsets.only(top: 10),
                    child: FutureBuilder<UserResponse>(
                      future: userResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(lang.t('loading'), style: TextStyle(color: AppColors.text));
                        }

                        if (snapshot.hasError) {
                          return Text(lang.t('loadingProfileFailed'), style: TextStyle(color: AppColors.text));
                        }

                        final user = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 18,
                                fontFamily: 'Poppins-Bold',
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfileScreen(onBack: (){}, userResponse: user),
                                    ),
                                  );
                                },
                                child: Text(
                                  lang.t('showProfile'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // --------- FIRST SECTION ---------
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    lang.t('settings'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 1),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('notifications'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 1),
                                    ),
                                  );
                      },
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.accent),
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        margin: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            '>',
                            style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 2),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('language'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 2),
                                    ),
                                  );
                      },
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.accent),
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        margin: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            '>',
                            style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 3),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('units'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 3),
                                    ),
                                  );
                      },
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.accent),
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        margin: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            '>',
                            style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // --------- SECOND SECTION ---------
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    lang.t('more'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 4),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('support'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 4),
                                    ),
                                  );
                      },
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.accent),
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        margin: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            '>',
                            style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 5),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('legalInformation'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 5),
                                    ),
                                  );
                      },
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.accent),
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        margin: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            '>',
                            style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 6),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('aboutUs'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 6),
                                    ),
                                  );
                      },
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.accent),
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        margin: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            '>',
                            style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),

            // ------- LOGOUT BUTTON --------
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwt_token');

                // 3. Przenieś do LoginScreen i wyczyść historię
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                lang.t('logout'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.background,
                ),
              ),
            ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
