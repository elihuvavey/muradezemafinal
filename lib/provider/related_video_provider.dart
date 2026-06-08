import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/related_video.dart';
import '../utils/user_prefs.dart';

class RelatedVideoProvider with ChangeNotifier {
  List<RelatedAudio> _relatedVideos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<RelatedAudio> get relatedVideos => _relatedVideos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchRelatedVideos(int episodeId) async {
    final url = '${dotenv.env['BASE_URL']}/video/episodes/related/$episodeId';

    // Set loading state to true when fetching
    _isLoading = true;
    _errorMessage = ''; // Clear any previous error message
    notifyListeners();

    try {
      Dio dio = createDio();
      final response = await dio.get(url,
          options: Options(headers: {
            
          }));

      print('response dd ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          _relatedVideos =
              data.map((item) => RelatedAudio.fromJson(item)).toList();

          // Clear the error and update the state
          _errorMessage = '';
        } else {
          throw Exception('No success in fetching related videos');
        }
      } else {
        throw Exception('Failed to load related videos');
      }
    } catch (error) {
      _errorMessage = 'Error fetching related videos: $error';
      debugPrint(_errorMessage);
    } finally {
      // Set loading to false after the fetch is complete
      _isLoading = false;
      notifyListeners();
    }
  }
}
