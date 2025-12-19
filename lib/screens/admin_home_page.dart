import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/screens/admin_manage_meetings.dart';
import 'package:frontend_rolly/screens/admin_manage_users.dart';
import 'package:frontend_rolly/screens/settings_screen.dart';
import 'package:frontend_rolly/units/app_units.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'education_screen.dart';
import 'training_screen.dart';
import 'meeting_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, required this.title});

  final String title;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String? selected;

  @override
  Widget build(BuildContext context) {

    if (selected == 'manageUsers') {
      return AdminManageUsers(
        onBack: () => setState(() => selected = null),
        onRefresh: () => setState((){}),
      );
    }
    
    if (selected == 'manageMeetings') {
      return AdminManageMeetings(
        onBack: () => setState(() => selected = null),
        onRefresh: () => setState((){}),
      );
    }
    
    if (selected == 'addCategory') {
      return AdminManageUsers(
        onBack: () => setState(() => selected = null),
        onRefresh: () => setState((){}),
      );
    } 

    if (selected == 'addTrick') {
      return AdminManageUsers(
        onBack: () => setState(() => selected = null),
        onRefresh: () => setState((){}),
      );
    } 


    return buildAdminWindow(context);
    
  }

  @override
  Widget buildAdminWindow(BuildContext context) {
    final lang = context.watch<AppLanguage>();

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.35),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      width: 30,
                      height: 30,
                      child: Center(
                        child: SvgPicture.asset(
                          AppConfig.logoImg,
                          height: 30,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Text(
                      widget.title,
                      style: GoogleFonts.dancingScript(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              
              Spacer(),
              IconButton(
                icon: Icon(Icons.settings, color: AppColors.text),
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        onBack: () {},
                      )
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = 'manageUsers';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.accent),
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.2,
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          lang.t('adminManageUsers'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontFamily: 'Poppins-Bold',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = 'manageMeetings';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.accent),
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.2,
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          lang.t('adminManageMeetings'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontFamily: 'Poppins-Bold',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = 'addCategory';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.accent),
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.2,
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                            lang.t('aminAddCategory'),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontFamily: 'Poppins-Bold',
                              fontSize: 20,
                            ),
                        ),
                      ),
                    )
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = 'addTrick';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.accent),
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.2,
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                            lang.t('adminAddTrick'),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontFamily: 'Poppins-Bold',
                              fontSize: 20,
                            ),
                        ),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

