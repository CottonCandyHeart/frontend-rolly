import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFEFBF3)),
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
        title: Text(
          widget.title,
          style: TextStyle(color: Color(0xFF7AB6B8)),
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
      color: Color(0xFF7AB6B8), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final bool isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF6DAEB0) : Colors.transparent,
                //borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.25,
              child: Icon(
                icons[index],
                color: Color(0xFFFEFBF3),
              ),
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
      child: Text('Home Screen'),
    );
  }
}

class EducationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Educaion Screen'),
    );
  }
}

class TrainingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Training Screen'),
    );
  }
}

class MeetingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Meeting Screen'),
    );
  }
}