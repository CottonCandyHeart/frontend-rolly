import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'education_screen.dart';
import 'training_screen.dart';
import 'meeting_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

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

    final List<Widget> _widgetOptions = <Widget>[
      HomeScreen(),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    width: 20,
                    height: 20,
                    child: Center(
                      child: Icon(
                        Icons.person_2_outlined,
                        color: AppColors.background,
                        size: 60,
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    widget.title,
                    style: TextStyle(
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
                  // TODO: akcja ustawień
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(child: _widgetOptions.elementAt(_currentIndex)),
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

