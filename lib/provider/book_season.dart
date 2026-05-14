import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:muradezema/utils/endpoint.dart';

import '../models/book_season.dart';
import '../utils/user_prefs.dart';

class BookSeasonProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<BookSeason> _books = [];

  List<BookSeason> get books => _books;

  Future<void> fetchBooks(int categoryId) async {
    try {
      final response =
          await _dio.get('${ApiConstants.baseUrl}/book/$categoryId/category',
              options: Options(headers: {
                'Authorization': 'Bearer ${HivePrefs.getString('token')}',
              }));
        print("response dfdfd ${response.data}");


      if (response.statusCode == 200 && response.data is List) {

        List<BookSeason> booksList = (response.data as List)
            .map((data) => BookSeason.fromJson(data))
            .toList();

        _books = booksList;
        debugPrint('bboks list $booksList');
      } else if (response.statusCode == 200 && response.data is Map) {
        debugPrint('bboks list ${response.data}');
        var bookData = response.data;
        BookSeason book = BookSeason.fromJson(bookData);
        _books = [book]; // Wrap the single book data into a list
      } else {
        _books =
            []; // If the response isn't in the expected format, set an empty list
        print("Unexpected response format or error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching booksdd: $e");
      _books = []; // Ensure we reset to empty list on error
    } finally {
      notifyListeners();
    }
  }
}
