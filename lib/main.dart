import 'package:flutter/material.dart';
import 'theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rolly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
        fontFamily: 'Poppins',
      ),
      home: const MyHomePage(title: 'Rolly'),
    );
  }
}

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
    final ThemeData theme = Theme.of(context);

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

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.home,
      Icons.menu_book,
      Icons.roller_skating,
      Icons.search,
    ];

    return Container(
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final bool isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.current : Colors.transparent,
                //borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.25,
              child: Icon(icons[index], color: AppColors.background),
            ),
          );
        }),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // ------------------------- TODO wczytywanie z bazy danych
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
                  child: Center(
                    child: Icon(
                      Icons.person_2_outlined,
                      color: AppColors.background,
                      size: 60,
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Container(
                  decoration: BoxDecoration(color: AppColors.accent),
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.5,
                  margin: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      'Profile info',
                      style: TextStyle(color: AppColors.text, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Progress',
                style: TextStyle(color: AppColors.text, fontSize: 12),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Last training',
                style: TextStyle(color: AppColors.text, fontSize: 12),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Last meeting',
                style: TextStyle(color: AppColors.text, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EducationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // -------------------------------------TODO wczytywanie z bazy danych
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Cathegory 1',
                style: TextStyle(
                  color: AppColors.text,
                  fontFamily: 'Poppins-Bold',
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Cathegory ',
                style: TextStyle(
                  color: AppColors.text,
                  fontFamily: 'Poppins-Bold',
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Cathegory 3',
                style: TextStyle(
                  color: AppColors.text,
                  fontFamily: 'Poppins-Bold',
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Training Screen', style: TextStyle(color: AppColors.text)),
    );
  }
}

class MeetingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Meeting Screen', style: TextStyle(color: AppColors.text)),
    );
  }
}
