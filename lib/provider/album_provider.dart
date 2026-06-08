import 'package:muradezema/utils/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/album_model.dart';
import '../utils/user_prefs.dart';

class AlbumProvider with ChangeNotifier {
  final Dio _dio = createDio();
  List<AlbumModel> _albums = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AlbumModel> get albums => _albums;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAlbums({required int artistId, required int page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _dio.get('${dotenv.env['BASE_URL']}/audio/albumList/$artistId',
              options: Options(headers: {
                
              }));

      if (response.statusCode == 200) {
        print('response albums  [36m${response.data} [0m');
        final data = response.data as List;
        _albums = data.map((json) => AlbumModel.fromJson(json)).toList();
        _errorMessage = null;
      }
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        print(
            'DioException while fetching albums: Status code  [36m${dioError.response?.statusCode} [0m, message:  [36m${dioError.message} [0m');
        _errorMessage =
            'Status code:  [36m${dioError.response?.statusCode} [0m, message:  [36m${dioError.message} [0m';
        notifyListeners();
      } else {
        print('DioException while fetching albums: ${dioError.message}');
        _errorMessage = dioError.message;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching albums: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }
}
