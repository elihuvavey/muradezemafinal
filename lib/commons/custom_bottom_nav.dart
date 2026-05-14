import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/dark_mode.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? Color(0xFF1C1C1E) : Color(0xfff0eded);
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      selectedItemColor: Color(0xffEACB1B),
      unselectedItemColor: textColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_camera_front),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_open_rounded),
          label: '',
        ),
      ],
    );
  }
}
