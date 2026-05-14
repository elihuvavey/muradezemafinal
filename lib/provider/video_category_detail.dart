import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_category_detail.dart';
import '../utils/user_prefs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoCategoryDetailProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = '${dotenv.env['BASE_URL']}/video';

  VideoCategoryDetail? _categoryDetail;
  bool _isLoading = false;

  VideoCategoryDetail? get categoryDetail => _categoryDetail;
  bool get isLoading => _isLoading;

  Future<void> fetchCategoryDetail(int categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('$baseUrl/$categoryId/category',
          options: Options(headers: {
            'Authorization': 'Bearer ${HivePrefs.getString('token')}',
          }));
      print('datas ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = Map<String, dynamic>.from(response.data);
        _categoryDetail = VideoCategoryDetail.fromJson(data);
      } else {
        throw Exception('Failed to load category details');
      }
    } catch (e) {
      print('Error fetching category detail: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
