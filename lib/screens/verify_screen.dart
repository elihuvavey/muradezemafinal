import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:muradezema/utils/user_prefs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../commons/custom_button.dart';
import '../commons/custom_text.dart';
import '../provider/dark_mode.dart';
import '../utils/api_services.dart';
import '../utils/nav_constants.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  Future<void> _verifyOtp(String email, bool isRegistration) async {
    setState(() {
      _isVerifying = true;
    });

    final api = ApiClient();
    final response = await api.post(
      "${dotenv.env['BASE_URL']}/verify_otp",
      data: {
        "otp": _otpController.text.trim(),
        "email": email,
        "is_registration": isRegistration
      },
    );

    setState(() {
      _isVerifying = false;
    });

    if (response['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Verified Successfully!")),
      );
      if (isRegistration == true) {
        Navigator.pushNamed(context, NavigationConstants.loginPage);
      } else {
        Navigator.pushNamed(
          context,
          NavigationConstants.resetPassword,
          arguments: {'token': response['data']['token']},
        );
        debugPrint('dataaa  [35m${response['data']['token']}');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Invalid OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String email = args?['email'] ?? '';
    bool isRegistration = args?['isRegistration'] ?? false;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100.h),
            Icon(
              Icons.verified_user_outlined,
              size: 80.sp,
              color: textColor,
            ),
            SizedBox(height: 30.h),
            CustomText(
              'Verify Your Account',
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            SizedBox(height: 15.h),
            CustomText(
              'Please enter the 6-digit verification code sent to your registered email or phone.',
              fontSize: 14.sp,
              color: textColor.withOpacity(0.8),
            ),
            SizedBox(height: 50.h),
            PinCodeTextField(
              appContext: context,
              controller: _otpController,
              length: 6,
              obscureText: false,
              animationType: AnimationType.scale,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: 56,
                fieldWidth: 44,
                activeFillColor:
                    isDarkMode ? Colors.grey[800] : Colors.blue[50],
                selectedFillColor:
                    isDarkMode ? Colors.grey[700] : Colors.blue[100],
                inactiveFillColor:
                    isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderWidth: 1,
                inactiveColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                selectedColor: Colors.blue,
                activeColor: Colors.green,
              ),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: backgroundColor,
              enableActiveFill: true,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
              beforeTextPaste: (text) => false,
            ),
            SizedBox(height: 40.h),
            _isVerifying
                ? LoadingAnimationWidget.inkDrop(color: textColor, size: 50)
                : CustomButton(
                    text: 'Verify Code',
                    onPressed: () {
                      if (_otpController.text.length == 6) {
                        _verifyOtp(email, isRegistration);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Please enter a valid 6-digit code")),
                        );
                      }
                    },
                  ),
            SizedBox(height: 30.h),
            TextButton(
              onPressed: () async {
                final api = ApiClient();
                final response = await api.post(
                  "${dotenv.env['BASE_URL']}/resend_verify_otp",
                  data: {
                    "email": email,
                  },
                  headers: {
                    
                    'Accept': 'application/json'
                  },
                );

                if (response.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            response['message'] ?? 'OTP resent successfully')),
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              child: CustomText(
                'Didn\'t get? Resend',
                fontSize: 16.sp,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
