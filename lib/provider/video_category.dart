import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:muradezema/models/video_category.dart';

import '../utils/user_prefs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoCategoryProvider extends ChangeNotifier {
  final Dio _dio = createDio();
  final String baseUrl = '${dotenv.env['BASE_URL']}/video';

  List<VideoCategory> _categories = []; 

  List<VideoCategory> get categories => _categories;

  Future<void> fetchPodcasts() async {
    try {
      final response = await _dio.get(baseUrl,
          options: Options(headers: {
            
          }));

      if (response.statusCode == 200) {
        List data = response.data;
        _categories = data.map((json) => VideoCategory.fromJson(json)).toList();

        // Notify listeners when data is updated
        notifyListeners();
      } else {
        throw Exception('Failed to load podcasts');
      }
    } catch (e) {
      print('Error fetching podcasts: $e');
      _categories = []; // Optionally clear the list if there's an error
      notifyListeners(); // Notify listeners even if there's an error
    }
  }
}
