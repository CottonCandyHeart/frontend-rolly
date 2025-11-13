import 'package:flutter/material.dart';
import '../theme/colors.dart';

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