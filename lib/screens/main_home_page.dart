import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'education_screen.dart';
import 'training_screen.dart';
import 'meeting_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguage>();

    final List<Widget> widgetOptions = <Widget>[
      HomeScreen(onPicked: (pageNo){ setState(() {
        _currentIndex=pageNo;
      });}),
      EducationScreen(),
      TrainingScreen(),
      MeetingScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.35),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  child: Row(
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
      body: Center(child: widgetOptions.elementAt(_currentIndex)),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

