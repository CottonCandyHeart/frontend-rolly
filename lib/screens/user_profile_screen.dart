
import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/measurements.dart';
import 'package:frontend_rolly/models/user_response.dart';
import 'package:frontend_rolly/screens/chosen_settings_screen.dart';
import 'package:frontend_rolly/services/user_service.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.onBack, required this.userResponse});

  final UserResponse userResponse;
  final VoidCallback onBack;

  @override
  State<UserProfileScreen> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfileScreen> {
  String? token;
  late Future<Measurements>? measurements;

  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('jwt_token');

    setState(() {
      token = storedToken;
      if (token != null) {
        measurements = UserService().getMeasurements(token!);
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
          title: Text(lang.t('userProfile'), style: TextStyle(color: AppColors.text)),
        ),
        body: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                    decoration: BoxDecoration(color: AppColors.primary),
                    padding: const EdgeInsets.all(2),
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 20),
                    child: const Center(
                      child: Icon(
                        Icons.person_2_outlined,
                        color: AppColors.background,
                        size: 80,
                      ),
                    ),
              ),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(color: AppColors.accent),
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.75,
                child: FutureBuilder<Measurements>(
                future: measurements,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(lang.t('loading'), style: TextStyle(color: AppColors.text));
                  }

                  if (snapshot.hasError) {
                    return Text(lang.t('loadingProfileFailed'), style: TextStyle(color: AppColors.text));
                  }

                  if (snapshot.hasData) {
                    final meas = snapshot.data!;
                    _weightController.text = meas.weight.toString();
                    _heightController.text = meas.height.toString();
                  }

                  return Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lang.t('username'),
                                style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                widget.userResponse.username,
                                style: TextStyle(color: AppColors.text),
                              ),
                            ),
                          ),
                        ],
                      ),

                      TableRow(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lang.t('weight'),
                                style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 50,
                                child: TextField(
                                  controller: _weightController,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.text),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.background,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      TableRow(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lang.t('height'),
                                style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _heightController,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.text),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.background,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                                        border: OutlineInputBorder(borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                
                            ),
                          ),
                        ],
                      ),

                      TableRow(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lang.t('level'),
                                style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                widget.userResponse.level,
                                style: TextStyle(color: AppColors.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              ),
            ),

            // -------- SETTINGS ---------
            // change email
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
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 7),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('changeEmail'),
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
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 7),
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

            // change passwd
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
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 8),
                                    ),
                                  );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('changePasswd'),
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
                                      builder: (context) => ChosenSettingsScreen(onBack: (){}, pageNo: 8),
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

            // delete account
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
                              lang.t('deleteAccount'),
                              style: TextStyle(color: Color.fromARGB(255, 219, 26, 26), fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
                  
          ]
        ),

      ),
    );
  }
}