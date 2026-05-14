import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:muradezema/utils/user_prefs.dart';

class UserProfile {
  final int id;
  final String userName;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String? dateOfBirth;
  final String gender;
  final String image;
  final String type;
  final String? bio;
  final String country;
  final String city;
  final String? deviceToken;
  final String status;
  final String date;
  final String createdAt;
  final String updatedAt;
  final int isBuy;

  UserProfile({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    this.dateOfBirth,
    required this.gender,
    required this.image,
    required this.type,
    this.bio,
    required this.country,
    required this.city,
    this.deviceToken,
    required this.status,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.isBuy,
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userName: json['user_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      dateOfBirth: json['date_of_birth']?.toString(), // null-safe
      gender: json['gender']?.toString() ?? '', // cast int to String
      image: json['image'] ?? '',
      type: json['type']?.toString() ?? '', // cast int to String
      bio: json['bio'],
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      deviceToken: json['device_token']?.toString(),
      status: json['status']?.toString() ?? '',
      date: json['date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isBuy: json['is_buy'] ?? 0,
    );
  }
}

class ProfileProvider with ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Dio _dio = Dio();

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = HivePrefs.getString('token');
      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/get_profile',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final json = response.data['result'][0] as Map<String, dynamic>;
        _profile = UserProfile.fromJson(json);
      } else {
        _error = "Failed to load profile.";
      }
    } on DioException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Replace the current profile with a new one
  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Alternative: Accept raw JSON map
  void setProfileFromJson(Map<String, dynamic> json) {
    _profile = UserProfile.fromJson(json);
    notifyListeners();
  }
}
