import 'package:dio/dio.dart';
import 'package:muradezema/utils/endpoint.dart';
import '../models/season_model.dart';
import '../utils/user_prefs.dart'; // Adjust the import as needed

class SeasonRepository {
  final Dio _dio = Dio();

  Future<List<Season>> fetchSeasons(String id) async {
    try {
      final String url = "${ApiConstants.seasons}$id";
      final response = await _dio.get(url, options: Options(headers: {
         'Authorization': 'Bearer ${HivePrefs.getString('token')}',
      }));

      if (response.statusCode == 200) {
        print('response seasons ${response.data}');
        List<dynamic> data = response.data;
        return Season.fromJsonList(data);
      } else {
        throw Exception('Failed to load seasons');
      }
    } catch (e) {
      throw Exception('Error fetching seasons: $e');
    }
  }
}
