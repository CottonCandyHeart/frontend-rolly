import 'package:flutter/material.dart';
import '../theme/colors.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});
  
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
                'Cathegory 2',
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