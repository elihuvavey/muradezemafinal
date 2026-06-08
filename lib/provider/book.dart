import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/book.dart';
import '../utils/user_prefs.dart';

class BookProvider with ChangeNotifier {
  final Dio _dio = createDio();
  final String _endpoint = '${dotenv.env['BASE_URL']}/books';

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(_endpoint,
          options: Options(headers: {
            
          }));

      if (response.statusCode == 200) {
        // The API returns a list of books.
        List data = response.data as List;
        _books = data.map((json) => Book.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load books: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
