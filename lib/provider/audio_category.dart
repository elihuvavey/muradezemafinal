import 'package:muradezema/utils/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/audio_category.dart';
import '../utils/api_headers.dart';

class AudioCategoryProvider with ChangeNotifier {
  final Dio _dio = createDio();
  List<AudioModel> _audios = [];
  bool _isLoading = false;

  List<AudioModel> get audios => _audios;
  bool get isLoading => _isLoading;

  Future<void> fetchAudios() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _dio.get('${dotenv.env['BASE_URL']}/audio/data/index/',
              options: Options(headers: authHeaders()));

      if (response.statusCode == 200) {
        print('response ${response.data}');
        final data = response.data as List;
        _audios = data.map((json) => AudioModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching audios: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
