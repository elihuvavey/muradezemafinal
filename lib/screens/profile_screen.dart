import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/provider/dark_mode.dart';
import 'package:muradezema/provider/profile_provider.dart';
import 'package:provider/provider.dart';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../commons/camera_gallery.dart';
import '../utils/api_services.dart';
import '../utils/user_prefs.dart';
import '../utils/nav_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );

  ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orangeAccent,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white70),
          titleTextStyle: TextStyle(
              color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    bool isDarkMode =
        Provider.of<DarkModeProvider>(context, listen: false).isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _darkTheme : _lightTheme,
      home: RefreshIndicator(
        onRefresh: () async {
          provider.fetchProfile();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(isDarkMode
                    ? Icons.wb_sunny_outlined
                    : Icons.nights_stay_outlined),
                onPressed: () {
                  Provider.of<DarkModeProvider>(context, listen: false)
                      .toggleDarkMode();
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
              ),
            ],
          ),
          body: Consumer<ProfileProvider>(builder: (context, value, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile picture + edit overlay
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60.r,
                          backgroundImage:
                              NetworkImage(value.profile?.image ?? ''),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen()),
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 16.r,
                              child: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),
                    Text(
                      value.profile?.fullName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value.profile?.userName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDarkMode ? Colors.white60 : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    _buildInfoCard(Icons.email, 'Email',
                        value.profile?.email ?? 'N/A', isDarkMode),
                    _buildInfoCard(Icons.phone, 'Phone',
                        value.profile?.mobileNumber ?? 'N/A', isDarkMode),
                    _buildInfoCard(
                        Icons.location_on,
                        'Address',
                        '${value.profile?.country ?? ''} ${value.profile?.city ?? ''}',
                        isDarkMode),

                    SizedBox(height: 32.h),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 12.h),
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        final api = ApiClient();
                        final response = await api.post(
                          '${dotenv.env['BASE_URL']}/logout',
                          headers: {
                            'Authorization':
                                'Bearer ${HivePrefs.getString('token')}',
                            'Accept': 'application/json'
                          },
                        );
                        debugPrint('response $response');

                        if (response['status'] == 200) {
                          Navigator.pop(context); // Close loading dialog
                          Navigator.pop(context); // Close profile dialog
                          Navigator.pushNamed(
                              context, NavigationConstants.loginPage);
                          HivePrefs.clear();
                        } else {
                          Navigator.pushNamed(
                              context, NavigationConstants.loginPage);
                          HivePrefs.clear();
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String label, String value, bool isDarkMode) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: isDarkMode
                              ? Colors.white60
                              : Colors.grey.shade600)),
                  SizedBox(height: 4.h),
                  Text(value,
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl, _mobileCtl, _emailCtl, _bioCtl;
  File? _pickedImage;
  bool _loading = false;
  bool _inited = false;

  final _pwFormKey = GlobalKey<FormState>();
  final TextEditingController _oldPwCtl = TextEditingController();
  final TextEditingController _newPwCtl = TextEditingController();
  final TextEditingController _confirmPwCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prov = Provider.of<ProfileProvider>(context, listen: false);
    await prov.fetchProfile();
    final p = prov.profile!;
    _nameCtl = TextEditingController(text: p.fullName);
    _mobileCtl = TextEditingController(text: p.mobileNumber);
    _emailCtl = TextEditingController(text: p.email);
    _bioCtl = TextEditingController(text: p.bio);
    setState(() => _inited = true);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final token = HivePrefs.getString('token');
    final dio = Dio();
    final form = FormData();
    form.fields
      ..add(MapEntry('user_id', HivePrefs.getInt('userId').toString()))
      ..add(MapEntry('full_name', _nameCtl.text))
      ..add(MapEntry('mobile_number', _mobileCtl.text))
      ..add(MapEntry('email', _emailCtl.text))
      ..add(MapEntry('device_token', 'dfdfdfdf'))
      ..add(MapEntry('bio', _bioCtl.text));

    // if (_pickedImage != null) {
    //   form.files.add(MapEntry(
    //     'image',
    //     await MultipartFile.fromFile(_pickedImage!.path,
    //         filename: 'avatar.jpg'),
    //   ));
    // }

    debugPrint('data is ${form}');

    try {
      final resp = await dio.post(
        '${dotenv.env['BASE_URL']}/update-profile',
        data: form,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      debugPrint('resp ${resp.data}');
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.data['message'])),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      debugPrint('error $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating your profile')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitPassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    // Call API to change password
    final token = HivePrefs.getString('token');
    final dio = Dio();
    setState(() => _loading = true);
    debugPrint('Starting password change...');
    debugPrint('Token: $token');
    try {
      final data = {
        'old_password': _oldPwCtl.text,
        'new_password': _newPwCtl.text,
        'user_id': HivePrefs.getInt('userId'),
      };
      debugPrint('Request data: $data');

      final resp = await dio.post(
        '${dotenv.env['BASE_URL']}/change_password',
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      debugPrint('Response status code: ${resp.statusCode}');
      debugPrint('Response data: ${resp.data}');

      if (resp.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.data['message'])),
        );
      } else {
        debugPrint('Non-200 status code received: ${resp.statusCode}');
        throw Exception('Password change failed');
      }
    } catch (e) {
      debugPrint('Error during password change: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error changing password')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showChangePwSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 16.h,
        ),
        child: Form(
          key: _pwFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 20.h),
              Text('Change Password',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _oldPwCtl,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _newPwCtl,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _confirmPwCtl,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != _newPwCtl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkModeProvider>(context).isDarkMode;
    final bgColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;

    if (!_inited) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.orangeAccent,
            size: 50.h,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: _showChangePwSheet,
            tooltip: 'Change Password',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar

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
                          : NetworkImage(
                              Provider.of<ProfileProvider>(context,
                                      listen: false)
                                  .profile!
                                  .image,
                            ) as ImageProvider,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (_pickedImage != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final token = HivePrefs.getString('token');
                              final dio = Dio();
                              final form = FormData();

                              form.files.add(MapEntry(
                                'image',
                                await MultipartFile.fromFile(_pickedImage!.path,
                                    filename: 'avatar.jpg'),
                              ));

                              debugPrint('form image body ${form.files}');

                              try {
                                final resp = await dio.post(
                                  '${dotenv.env['BASE_URL']}/update_profile_image',
                                  data: form,
                                  options: Options(headers: {
                                    'Authorization': 'Bearer $token',
                                  }),
                                );

                                debugPrint('body profile image ${resp.data}');

                                if (resp.statusCode == 200) {
                                  Provider.of<ProfileProvider>(context,
                                          listen: false)
                                      .fetchProfile();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Profile picture updated')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to update profile picture')),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (_pickedImage != null)
                Padding(
                  padding: EdgeInsets.all(8.r),
                  child: ElevatedButton(
                   onPressed: () async {
                      final token = HivePrefs.getString('token');
                      final dio = Dio();
                      final form = FormData();

                      form.files.add(MapEntry(
                        'image',
                        await MultipartFile.fromFile(_pickedImage!.path,
                            filename: 'avatar.jpg'),
                      ));

                      debugPrint('form image body ${form.files}');

                      try {
                        final resp = await dio.post(
                          '${dotenv.env['BASE_URL']}/update_profile_image',
                          data: form,
                          options: Options(headers: {
                            'Authorization': 'Bearer $token',
                          }),
                        );

                        debugPrint('body profile image ${resp.data}');

                        if (resp.statusCode == 200) {
                          Provider.of<ProfileProvider>(context, listen: false)
                              .fetchProfile();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Profile picture updated')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to update profile picture')),
                        );
                      }
                    },
                    child: Text("Save Profile Picture"),
                  ),
                ),

              SizedBox(height: 24.h),

              // Full Name
              TextFormField(
                controller: _nameCtl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 16.h),

              // Mobile Number
              TextFormField(
                controller: _mobileCtl,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 16.h),

              // Email
              TextFormField(
                controller: _emailCtl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return regex.hasMatch(v) ? null : 'Invalid email';
                },
              ),
              SizedBox(height: 16.h),

              // Bio
              TextFormField(
                controller: _bioCtl,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
