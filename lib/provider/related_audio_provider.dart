import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:muradezema/utils/endpoint.dart';
import '../models/related_audio.dart';
import '../utils/user_prefs.dart'; // Import your model

class RelatedAudioProvider with ChangeNotifier {
  List<RelatedAudio> _relatedAudios = [];
  bool _isLoading = false;

  List<RelatedAudio> get relatedAudios => _relatedAudios;
  bool get isLoading => _isLoading;

  final Dio _dio = createDio();

  Future<void> fetchRelatedAudios(int audioId) async {
    _isLoading = true;
    notifyListeners();

    final url = '${ApiConstants.podcasts}/related/$audioId';
    print('url : $url');

    try {
      final response = await _dio.get(url, options: Options(headers: {
         
      }));
      print('Response related: ${response.data}');

      if (response.statusCode == 200) {

        final List<dynamic> data = response.data['data'];
        _relatedAudios = data.map((json) => RelatedAudio.fromJson(json)).toList();
        print('Related audios: $_relatedAudios');
      } else {
        _relatedAudios = [];
      }
    } catch (e) {
      _relatedAudios = [];
      if (kDebugMode) {
        print('Error fetching related audios: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
