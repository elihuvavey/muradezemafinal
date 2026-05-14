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

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // Loading state

  Future<void> _sendResetLink() async {
    setState(() {
      _isLoading = true;
    });

    final api = ApiClient();
    final url = "${dotenv.env['BASE_URL']}/forget_password";
    final response = await api.post(
      url,
      data: {"email": _emailController.text.trim()},
    );

    setState(() {
      _isLoading = false;
    });

    debugPrint('resp $response');

    if (response['status'] == 200) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("OTP sent successfully! Check your email.")),
      );

      // Navigate to verify screen after delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamed(context, NavigationConstants.verify, arguments: {
          'email': _emailController.text,
          'isRegistration': false
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'] ?? "Something went wrong")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60.h),
            CustomText(
              'Forgot Password?',
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            SizedBox(height: 10.h),
            CustomText(
              'Enter your email to receive a password reset link.',
              fontSize: 14.sp,
              color: textColor.withOpacity(0.8),
            ),
            SizedBox(height: 30.h),

            /// Email Input Field
            CustomInputField(
              hintText: 'Enter your email address',
              icon: Icons.email,
              controller: _emailController,
            ),

            SizedBox(height: 40.h),

            /// Show loading animation or button
            _isLoading
                ? LoadingAnimationWidget.inkDrop(
                    color: textColor,
                    size: 50,
                  )
                : CustomButton(
                    text: 'Send Reset OTP',
                    onPressed: _sendResetLink,
                  ),

            SizedBox(height: 20.h),

            /// Back to Login
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, NavigationConstants.loginPage);
              },
              child: CustomText(
                'Back to Login',
                fontSize: 14.sp,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
