import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../commons/custom_button.dart';
import '../commons/custom_input.dart';
import '../commons/custom_text.dart';
import '../provider/dark_mode.dart';
import '../utils/api_services.dart';
import '../utils/nav_constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  late String token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    token = args?['token'] ?? '';
  }

  Future<void> _resetPassword() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final api = ApiClient();
    final url = "${dotenv.env['BASE_URL']}/reset_password";
    final response = await api.post(url, data: {
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    }, headers: {
      'Authorization': 'Bearer $token'
    });

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successfully")),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamed(context, NavigationConstants.loginPage);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['error'] ?? "Failed to reset password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 60.h),
            CustomText(
              'Reset Password',
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            SizedBox(height: 10.h),
            CustomText(
              'Enter your new password below.',
              fontSize: 14.sp,
              color: textColor.withOpacity(0.8),
            ),
            SizedBox(height: 30.h),
            CustomInputField(
                hintText: 'New Password',
                icon: Icons.lock_outline,
                controller: _passwordController,
                isPassword: true),
            SizedBox(height: 20.h),
            CustomInputField(
                hintText: 'Confirm Password',
                icon: Icons.lock,
                controller: _confirmPasswordController,
                isPassword: true),
            SizedBox(height: 40.h),
            _isLoading
                ? LoadingAnimationWidget.inkDrop(color: textColor, size: 50)
                : CustomButton(
                    text: 'Reset Password',
                    onPressed: _resetPassword,
                  ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
