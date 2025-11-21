import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';

class UnitsWidget extends StatefulWidget {
  const UnitsWidget({super.key});

  @override
  State<UnitsWidget> createState() => _UnitsWidgetState();
}

class _UnitsWidgetState extends State<UnitsWidget> {
  String selectedCode = 'met';

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<AppLanguage>();

    final units = {
      'met': unit.t('metrical'),
      'imp': unit.t('imperial'),
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unit.t('units'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),

          ...units.entries.map(
            (entry) => _buildOption(
              code: entry.key,
              label: entry.value,
              lang: unit,
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
