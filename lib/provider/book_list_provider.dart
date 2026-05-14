import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/user_prefs.dart';

class BookModel {
  final int id;
  final int? audioId;
  final String name;
  final String? image;
  final String? audio;
  final String? audioDuration;
  final String? description;
  final String type;
  final int? priceInLocal;
  final int? priceInForeign;
  final int isPremium;
  final int played;
  final String status;
  final int? audiobookId;
  final int? seasonId;
  final bool isPurchased;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookModel({
    required this.id,
    this.audioId,
    required this.name,
    this.image,
    this.audio,
    this.audioDuration,
    this.description,
    required this.type,
    this.priceInLocal,
    this.priceInForeign,
    required this.isPremium,
    required this.played,
    required this.status,
    this.audiobookId,
    this.seasonId,
    required this.isPurchased,
    this.createdAt,
    this.updatedAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('Failed to parse int from string: $value');
          return 0;
        }
      }
      return 0;
    }

    int? safeParseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('Failed to parse nullable int from string: $value');
          return null;
        }
      }
      return null;
    }

    return BookModel(
      id: safeParseInt(json['id']),
      audioId: safeParseNullableInt(json['audio_id']),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      audio: json['audio']?.toString(),
      audioDuration: json['audio_duration']?.toString(),
      description: json['description']?.toString(),
      type: json['type']?.toString() ?? '',
      priceInLocal: safeParseNullableInt(json['price_in_local']),
      priceInForeign: safeParseNullableInt(json['price_in_foreign']),
      isPremium: safeParseInt(json['is_premium']),
      played: safeParseInt(json['played']),
      status: json['status']?.toString() ?? '',
      audiobookId: safeParseNullableInt(json['audiobook_id']),
      seasonId: safeParseNullableInt(json['season_id']),
      isPurchased: json['is_purchased'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }
}

class BookService {
  final Dio _dio = Dio();

  Future<List<BookModel>> fetchBooksBySubcatId(String subcatId) async {
    final String url = '${dotenv.env['BASE_URL']}/book/category/$subcatId';
    try {
      final response = await _dio.get(url,
          options: Options(headers: {
            'Authorization': 'Bearer ${HivePrefs.getString('token')}',
          }));
      if (response.statusCode == 200) {
        print('books data ${response.data}');
        List data = response.data;
        return data.map((json) => BookModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('url ${dotenv.env['BASE_URL']}/book/category/$subcatId');
      throw Exception('Error fetching booksee: $e');
    }
  }
}

class BookListProvider with ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _books = [];
  bool _isLoading = false;
  String? _error;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBooks(String subcatId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _bookService.fetchBooksBySubcatId(subcatId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
