import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/dark_mode.dart';
import '../utils/user_prefs.dart';

class TopSellingCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String price;
  final String foreignPrice;

  final String category;
  final int id;
  bool? isPurchased;

   TopSellingCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.foreignPrice,
    required this.category,
    required this.id,
    this.isPurchased
  });

  @override
  Widget build(BuildContext context) {
    bool? isLocal = HivePrefs.getBool('isLocal');
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode
        ? const Color.fromARGB(255, 43, 43, 45)
        : const Color.fromARGB(255, 223, 222, 222);
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),

          // Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildOutlinedTag(category, textColor),
                    SizedBox(width: 8),
                   isPurchased?? false ? SizedBox.shrink() :  _buildOutlinedTag(
                        isLocal ?? false ? 'ETB$price' : '\$$foreignPrice',
                        textColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedTag(String text, Color textColor) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 13),
      ),
    );
  }
}
