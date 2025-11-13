import 'package:flutter/material.dart';
import '../theme/colors.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Meeting Screen', style: TextStyle(color: AppColors.text)),
    );
  }
}