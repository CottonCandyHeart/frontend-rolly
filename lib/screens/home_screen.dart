import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
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