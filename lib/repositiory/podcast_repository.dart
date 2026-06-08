import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:muradezema/utils/endpoint.dart';

import '../models/podcast_model.dart';

class PodcastRepository {
  final Dio _dio = createDio();

  Future<List<Podcast>> fetchPodcasts() async {
    try {
      final response = await _dio.get(ApiConstants.podcasts);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        print('response pod caset after ${response.data}');

        return Podcast.fromJsonList(data);
      } else {
        print('response pod caset ${response.data['data']}');
        print('response pod caset  ${response.statusCode}');
        throw Exception('Failed to load podcasts');
      }
    } catch (e) {
      print('url is ${ApiConstants.podcasts}');
      print('Error fetching podcasts: $e');
      throw Exception('Error fetching podcasts: $e');
    }
  }
}
