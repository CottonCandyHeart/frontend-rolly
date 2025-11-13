import 'package:flutter/material.dart';
import '../theme/colors.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Training Screen', style: TextStyle(color: AppColors.text)),
    );
  }
}