import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/dark_mode.dart';
import 'custom_text.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Color color; 
  final bool isSelected; 

  const CategoryChip({
    required this.label,
    required this.color,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    // Set background and text colors based on selection and dark mode status
    Color backgroundColor = isSelected
        ? (isDarkMode ? Colors.orange : Colors.orangeAccent)
        : (isDarkMode ? const Color(0xFF1C1C1E) : Colors.white);
    Color textColor = isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.black);
    Color borderColor = isSelected
        ? (isDarkMode ? Colors.orange : Colors.orangeAccent)
        : (isDarkMode ? Colors.white24 : Colors.black26);

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8, top: 2),
        child: Center(
          child: CustomText(
            label,
            fontSize: 14.sp,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
