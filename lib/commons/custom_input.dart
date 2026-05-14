import 'package:flutter/material.dart';
import 'package:muradezema/screens/search_screen.dart';
import 'package:provider/provider.dart';
import '../provider/dark_mode.dart';

class CustomInputField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool? isSearch;
  final int? index;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.isSearch,
    this.index,
    this.controller,
    this.validator,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Colors.white24 : Colors.black12;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final isSearch = widget.isSearch ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          if (isSearch) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(initialTab: widget.index ?? 0),
              ),
            );
          }
        },
        child: TextFormField(
          enabled: !isSearch,
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          validator: widget.validator,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor,
            prefixIcon: Icon(widget.icon, color: textColor),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: textColor),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: textColor.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
