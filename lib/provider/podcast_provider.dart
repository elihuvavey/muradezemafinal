import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/user_prefs.dart';

class EpisodesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _episodes = [];
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get episodes => _episodes;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch related episodes from the API
  Future<void> fetchEpisodes(int seasonId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      Dio dio = Dio();
      final response = await dio.get(
          '${dotenv.env['BASE_URL']}/video/episodes/related/$seasonId',
          options: Options(headers: {
            'Authorization': 'Bearer ${HivePrefs.getString('token')}',
          }));

      if (response.statusCode == 200) {
        _episodes = List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        _error = 'Failed to load episodes';
      }
    } catch (e) {
      _error = 'Failed to load episodes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
