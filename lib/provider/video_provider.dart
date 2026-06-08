import 'package:muradezema/utils/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:muradezema/utils/endpoint.dart';
import '../models/video_model.dart';
import '../utils/user_prefs.dart';

class VideoProvider with ChangeNotifier {
  final Dio _dio = createDio(); 
  List<Video> _videos = [];

  List<Video> get videos => _videos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchVideos() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Fetching videoss from ${ApiConstants.videosUrl}");

      final response = await _dio.get(ApiConstants.videosUrl, options: Options(headers: {
         
      }));

      print("Response status: ${response.statusCode}");
      print("Raw response data: ${response.data}");

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        _videos = data.map((json) {
          final video = Video.fromJson(json);
          print("Parsed video: ${video.name}, ID: ${video.id}");
          return video;
        }).toList();
      } else {
        print("Failed to fetch videos. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Dio response error data: ${e.response?.data}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
