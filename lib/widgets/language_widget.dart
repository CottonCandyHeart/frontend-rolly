import 'package:flutter/material.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';
import '../lang/app_language.dart';

class LanguageWidget extends StatefulWidget {
  const LanguageWidget({super.key});

  @override
  State<LanguageWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  String selectedCode = "eng";

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguage>();

    final languages = {
      'pl': lang.t('language_pl'),
      'eng': lang.t('language_en'),
      'fr': lang.t('language_fr'),
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('language'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),

          ...languages.entries.map(
            (entry) => _buildOption(
              code: entry.key,
              label: entry.value,
              lang: lang,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String code,
    required String label,
    required AppLanguage lang,
  }) {
    final bool isSelected = selectedCode == code;

    return GestureDetector(
      onTap: () {
        setState(() => selectedCode = code);
        lang.changeLanguage(code);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.accent, 
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: AppColors.text),
            ),

            if (isSelected)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: AppColors.background,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
