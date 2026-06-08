import 'package:muradezema/utils/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:muradezema/utils/endpoint.dart';
import '../models/vide_id_model.dart';
import '../utils/user_prefs.dart';

class VideoIdProvider with ChangeNotifier {
  Episode? _episode;
  bool _isLoading = false;

  Episode? get episode => _episode;
  bool get isLoading => _isLoading;

  Future<void> fetchEpisode(int id) async {
    _isLoading = true;
    notifyListeners();

    final url = '${ApiConstants.videosUrl}/$id';

    try {
      final response = await createDio().get(url, options: Options(headers: {
         
      }));
      print('Response status: ${response.statusCode}');
      print('Raw response data id: ${response.data}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _episode = Episode.fromJson(response.data['data']);
      } else {
        _episode = null;
      }
    } catch (e) {
      print('Error fetching episode: $e');
      _episode = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
