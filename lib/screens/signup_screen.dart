import 'package:muradezema/utils/dio_client.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../commons/camera_gallery.dart';
import '../commons/custom_button.dart';
import '../commons/custom_input.dart';
import '../commons/custom_text.dart';
import '../provider/dark_mode.dart';
import '../utils/api_services.dart';
import '../utils/endpoint.dart';
import 'package:intl/intl.dart';

import '../utils/nav_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final userNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  DateTime? selectedDate;
  String selectedGender = 'Male';
  String selectedCity = 'Addis Abeba';
  String selectedCountry = 'Ethiopia';

  Future<void> _register() async {
    debugPrint('Registering user... url ${ApiConstants.register}');
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dio = createDio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final data = {
      "contact_type": "email",
      "username": userNameController.text,
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "email": emailController.text,
      "mobile_number": phoneNumberController.text,
      "password": passwordController.text,
      "date_of_birth": "2025-04-23",
      "country": selectedCountry,
      "city": selectedCity,
      "gender": selectedGender == 'Male' ? 1 : 2,
    };

    try {
      final response = await dio.post(ApiConstants.register, data: data);

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('response is  [35m${response.data}');

        final data = response.data;
        debugPrint('response  [35m${response.data}');

        if (data is Map<String, dynamic>) {
          final status = data['status'];
          final message = data['message'];
          final errors = data['errors'];

          if (status == 400) {
            String errorMessage = 'Something went wrong';
            if (message != null) {
              errorMessage = message;
            } else if (errors is List && errors.isNotEmpty) {
              errorMessage = errors.first.toString();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
            return;
          } else if (status == 200) {
            Navigator.pushNamed(context, NavigationConstants.verify,
                arguments: {
                  'email': emailController.text,
                  'isRegistration': true
                });
            return;
          }

          // Fallback generic success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message ?? 'Operation successful')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected response format')),
          );
        }
      } else {
        debugPrint('error  [35m${response.data}');
        _handleError(response.statusCode);
      }
    } on DioException catch (e) {
      debugPrint('e $e');
      setState(() => _isLoading = false);
      if (e.response != null) {
        _handleError(e.response!.statusCode);
      } else {
        _showError('Connection failed. Please check your internet.');
      }
    } catch (e) {
      debugPrint('error $e');
      setState(() => _isLoading = false);
      _showError('Something went wrong. Please try again later.');
    }
  }

  void _handleError(int? statusCode) {
    switch (statusCode) {
      case 400:
        _showError('Bad request. Please check your input.');
        break;
      case 401:
        _showError('Unauthorized. Please log in again.');
        break;
      case 409:
        _showError('User already exists.');
        break;
      case 500:
        _showError('Server error. Please try again later.');
        break;
      default:
        _showError('An unknown error occurred. Code: $statusCode');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildStepTitle(String title, {double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: CustomText(
        title,
        fontSize: fontSize ?? 18.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  File? _pickedImage;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => MediaSourceSheet(
                              onImageSelected: (file) {
                                setState(() => _pickedImage = File(file.path));
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 8)
                            ],
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : const AssetImage('assets/images/logo.png')
                                      as ImageProvider,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      CustomText('Create an Account',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                      CustomText("Let's set up your profile step-by-step.",
                          fontSize: 16, color: textColor),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _buildStepTitle('Basic Information'),
                CustomInputField(
                  hintText: 'User Name',
                  controller: userNameController,
                  icon: Icons.person,
                  validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                ),
                CustomInputField(
                  hintText: 'First Name',
                  controller: firstNameController,
                  icon: Icons.person,
                  validator: (val) => val!.isEmpty ? 'Enter first name' : null,
                ),
                CustomInputField(
                  hintText: 'Last Name',
                  controller: lastNameController,
                  icon: Icons.person,
                  validator: (val) => val!.isEmpty ? 'Enter last name' : null,
                ),
                _buildStepTitle('Contact Information'),
                CustomInputField(
                  hintText: 'Email',
                  controller: emailController,
                  icon: Icons.email,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(val)) return 'Invalid email';
                    return null;
                  },
                ),
                CustomInputField(
                  hintText: 'Phone',
                  controller: phoneNumberController,
                  icon: Icons.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Phone number is required';

                    return null;
                  },
                ),
                _buildStepTitle('Security'),
                CustomInputField(
                  hintText: 'Password',
                  controller: passwordController,
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Min 6 characters' : null,
                ),
                CustomInputField(
                  hintText: 'Confirm Password',
                  controller: confirmPasswordController,
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (val) => val != passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                _buildStepTitle('Personal Details'),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(
                        gender,
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedGender = value!),
                  dropdownColor: backgroundColor,
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Ethiopia', 'Other'].map((country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedCountry = value!),
                  dropdownColor: backgroundColor,
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Addis Abeba', 'Other'].map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCity = value!),
                  dropdownColor: backgroundColor,
                ),
                SizedBox(height: 12.h),
                SizedBox(height: 20.h),
                Center(
                  child: _isLoading
                      ? LoadingAnimationWidget.inkDrop(
                          color: textColor, size: 40)
                      : CustomButton(text: 'Register', onPressed: _register),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
