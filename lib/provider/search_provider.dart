import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/user_prefs.dart';

class SearchResult {
  /// A map from sub‐collection name (e.g. “podcasts”, “episodes”) to
  /// its list of items.
  final Map<String, List<Map<String, dynamic>>> sections;
  final String type;

  SearchResult({
    required this.sections,
    required this.type,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json, String type) {
    final sections = <String, List<Map<String, dynamic>>>{};

    // e.g. json['video'] → { "podcasts": […], "episodes": […], "seasons": […] }
    final data = json[type] as Map<String, dynamic>?;

    if (data != null) {
      data.forEach((sectionName, rawList) {
        if (rawList is List) {
          // ensure each element is a Map<String, dynamic>
          sections[sectionName] = List<Map<String, dynamic>>.from(rawList);
        }
      });
    }

    return SearchResult(sections: sections, type: type);
  }
}

class SearchProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _errorMessage;
  SearchResult? _result;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SearchResult? get result => _result;

  Future<void> search(String query, String type) async {
    _isLoading = true;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    final url = '${dotenv.env['BASE_URL']}/search'
        '?query=${Uri.encodeComponent(query)}'
        '&type=${Uri.encodeComponent(type)}';

    print('url $url');

    try {
      final response = await _dio.get(url,
          options: Options(headers: {
            'Authorization': 'Bearer ${HivePrefs.getString('token')}',
          }));
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        print('resp ${response.data}');
        _result = SearchResult.fromJson(response.data, type);
        print('result $_result');
      } else {
        _errorMessage = 'Error: ${response.statusCode}';
      }
    } on DioError catch (e) {
      if (e.response != null) {
        _errorMessage =
            'Error: ${e.response?.statusCode} – ${e.response?.statusMessage}';
      } else {
        _errorMessage = 'Network error: Unable to reach the server';
      }
      debugPrint(e.toString());
    } catch (e) {
      print('e $e');
      _errorMessage = 'Unexpected error: $e';
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }
}
