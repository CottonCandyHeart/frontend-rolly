import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  bool activity = true;
  bool community = true;
  bool trainingReminder = false;
  bool updates = true;

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('notifications'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 20),

          _buildRow(lang.t('activity'), activity, (v) {
            setState(() => activity = v);
          }),

          _buildRow(lang.t('society'), community, (v) {
            setState(() => community = v);
          }),

          _buildRow(lang.t('trainingReminder'), trainingReminder, (v) {
            setState(() => trainingReminder = v);
          }),

          _buildRow(lang.t('updates'), updates, (v) {
            setState(() => updates = v);
          }),
        ],
      ),
    );
  }

  Widget _buildRow(String text, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16, color: AppColors.text),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          )
        ],
      ),
    );
  }
}
