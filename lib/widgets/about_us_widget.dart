
import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';

class AboutUsWidget extends StatelessWidget {
  const AboutUsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(
            lang.t('aboutUs'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 20),

          _section(
            title: lang.t('author'),
            content:
                "Weronika Bucewka"
          ),

          const SizedBox(height: 40),
          Text(
            lang.t('R'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
