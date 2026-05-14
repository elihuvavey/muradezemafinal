import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../commons/custom_button.dart';
import '../commons/custom_input.dart';
import '../commons/custom_text.dart';
import '../provider/dark_mode.dart';
import '../utils/api_services.dart';
import '../utils/endpoint.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    // Navigator.pushNamed(context, NavigationConstants.audioHome);

    setState(() {
      _isLoading = true; // Start loading
    });

    final api = ApiClient();

    final response = await api.post(
      ApiConstants.login,
      data: {
        "type": 3,
        "email": emailController.text,
        "password": passwordController.text,
      },
      // headers: {"Authorization": "Bearer YOUR_TOKEN"},
    );

    setState(() {
      _isLoading = false; // Stop loading
    });

    if (response.isNotEmpty) {
      debugPrint('response burda $response');

      if (response['status'] != 200) {
        String errorMessage = response['message'] is Map
            ? response['message']['message'] ?? response['message'].toString()
            : response['message']?.toString() ?? 'An error occurred';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        if (response['message']['data']['email'] != null) {
          Navigator.pushNamed(context, NavigationConstants.verify, arguments: {
            'email': response['message']['data']['email'],
            'isRegistration': true
          });
        }
        return;
      }

      HivePrefs.saveBool('isLoggedIn', true);
      HivePrefs.saveInt("userId", response["result"][0]['id']);
      HivePrefs.saveString("fullName", response["result"][0]['full_name']);
      HivePrefs.saveString("image", response["result"][0]['image']);
      HivePrefs.saveString("token", response["result"][0]['token']);

      Navigator.pushNamed(context, NavigationConstants.audioHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? Color(0xFF1C1C1E) : Colors.white;
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
            CustomText('Welcome Back',
                fontSize: 28.sp, fontWeight: FontWeight.bold, color: textColor),
            SizedBox(height: 30.h),
            CustomInputField(
              controller: emailController,
              hintText: 'Enter your email address',
              icon: Icons.email,
            ),
            CustomInputField(
              controller: passwordController,
              hintText: 'Enter your password',
              icon: Icons.lock,
              isPassword: true,
            ),
            SizedBox(height: 40.h),
            _isLoading
                ? LoadingAnimationWidget.inkDrop(
                    color: textColor,
                    size: 50,
                  )
                : CustomButton(text: 'Login', onPressed: _login),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, NavigationConstants.forgetPassword);
                },
                child: CustomText(
                  'Forgot Password?',
                  fontSize: 14.sp,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  "Don't have an account? ",
                  fontSize: 14,
                  color: textColor,
                ),
                SizedBox(
                  width: 3.w,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                        context, NavigationConstants.registerPage);
                  },
                  child: CustomText(
                    'Register',
                    fontSize: 14.sp,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
