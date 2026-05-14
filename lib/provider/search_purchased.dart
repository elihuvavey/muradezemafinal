// lib/providers/search_purchases_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muradezema/utils/user_prefs.dart';

abstract class MediaItem {
  int get id;
  String get title;
  String? get image;
  String? get description;
  int? get priceInLocal;
  int? get priceInForeign;
  bool? get isCategory;
  DateTime? get createdAt;
  DateTime? get updatedAt;
}

class AudioResponse {
  final List<AudioItem> audio;

  AudioResponse({required this.audio});

  factory AudioResponse.fromJson(Map<String, dynamic> json) {
    return AudioResponse(
      audio: (json['audio'] as List)
          .map((item) => AudioItem.fromJson(item))
          .toList(),
    );
  }
}

class AudioItem implements MediaItem {
  final int id;
  final int? albumId;
  final int? languageId;
  final String title;
  final String? image;
  final String? audio;
  final String type;
  final String? duration;
  final String? description;
  final int isPremium;
  final int status;
  final String? genre;
  final int? priceInLocal;
  final int? priceInForeign;
  final String? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? artistName;
  final Album? album;
  final bool? isCategory;

  AudioItem({
    required this.id,
    this.albumId,
    this.languageId,
    required this.title,
    this.image,
    this.audio,
    required this.type,
    this.duration,
    this.description,
    required this.isPremium,
    required this.status,
    this.genre,
    this.priceInLocal,
    this.priceInForeign,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.artistName,
    this.album,
    this.isCategory,
  });

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing AudioItem with data: $json');

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

      final item = AudioItem(
        id: safeParseInt(json['id']),
        albumId: safeParseNullableInt(json['album_id']),
        languageId: safeParseNullableInt(json['language_id']),
        title: json['title']?.toString() ?? '',
        image: json['image']?.toString(),
        audio: json['audio']?.toString(),
        type: json['type']?.toString() ?? '',
        duration: json['duration']?.toString(),
        description: json['description']?.toString(),
        isPremium: safeParseInt(json['is_premium']),
        status: safeParseInt(json['status']),
        genre: json['genre']?.toString(),
        priceInLocal: safeParseNullableInt(json['price_in_local']),
        priceInForeign: safeParseNullableInt(json['price_in_foreign']),
        date: json['date']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : null,
        artistName: json['artist_name']?.toString(),
        album: json['album'] != null ? Album.fromJson(json['album']) : null,
        isCategory: json['is_category']??false,
      );
      print('Successfully parsed AudioItem');
      return item;
    } catch (e, stackTrace) {
      print('Error parsing AudioItem: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }
}

class Album {
  final int id;
  final int? artistId;
  final String title;
  final String? image;
  final int? priceInLocal;
  final int? priceInForeign;
  final int? year;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Artist? artist;
  final bool? isCategory;

  Album({
    required this.id,
    this.artistId,
    required this.title,
    this.image,
    this.priceInLocal,
    this.priceInForeign,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.artist,
    this.isCategory,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
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

    return Album(
      id: safeParseNullableInt(json['id']) ?? 0,
      artistId: safeParseNullableInt(json['artist_id']),
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString(),
      priceInLocal: safeParseNullableInt(json['price_in_local']),
      priceInForeign: safeParseNullableInt(json['price_in_foreign']),
      year: safeParseNullableInt(json['year']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      artist: json['artist'] != null ? Artist.fromJson(json['artist']) : null,
      isCategory: json['is_category']??false,
    );
  }
}

class Artist {
  final int id;
  final String name;
  final String? genre;
  final String? dob;
  final String? country;
  final String? bio;
  final String? website;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Artist({
    required this.id,
    required this.name,
    this.genre,
    this.dob,
    this.country,
    this.bio,
    this.website,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      genre: json['genre'],
      dob: json['dob'],
      country: json['country'],
      bio: json['bio'],
      website: json['website'],
      image: json['image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class VideoResponse {
  final List<VideoItem> video;

  VideoResponse({required this.video});

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    return VideoResponse(
      video: (json['video'] as List)
          .map((item) => VideoItem.fromJson(item))
          .toList(),
    );
  }
}

class VideoItem implements MediaItem {
  final int id;
  final int? audioId;
  final String name;
  final String? image;
  final String type;
  final String? audio;
  final String? audioDuration;
  final String? description;
  final int? isPremium;
  final int played;
  final int? priceInLocal;
  final int? priceInForeign;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? podcastId;
  final int? seasonId;
  final bool? isCategory;
  @override
  String get title => name;

  VideoItem({
    required this.id,
    this.audioId,
    required this.name,
    this.image,
    required this.type,
    this.audio,
    this.audioDuration,
    this.description,
    this.isPremium,
    required this.played,
    this.priceInLocal,
    this.priceInForeign,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.podcastId,
    this.seasonId,
    this.isCategory,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing VideoItem with data: $json');

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

      final item = VideoItem(
        id: safeParseInt(json['id']),
        audioId: safeParseNullableInt(json['audio_id']),
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString(),
        type: json['type']?.toString() ?? '',
        audio: json['audio']?.toString(),
        audioDuration: json['audio_duration']?.toString(),
        description: json['description']?.toString(),
        isPremium: safeParseNullableInt(json['is_premium']),
        played: safeParseInt(json['played']),
        priceInLocal: safeParseNullableInt(json['price_in_local']),
        priceInForeign: safeParseNullableInt(json['price_in_foreign']),
        status: json['status']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : null,
        podcastId: safeParseNullableInt(json['podcast_id']),
        seasonId: safeParseNullableInt(json['season_id']),
        isCategory: json['is_category']??false,
      );
      print('Successfully parsed VideoItem');
      return item;
    } catch (e, stackTrace) {
      print('Error parsing VideoItem: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }
}

class BookResponse {
  final List<BookItem> book;

  BookResponse({required this.book});

  factory BookResponse.fromJson(Map<String, dynamic> json) {
    return BookResponse(
      book: (json['book'] as List)
          .map((item) => BookItem.fromJson(item))
          .toList(),
    );
  }
}

class BookItem implements MediaItem {
  final int id;
  final int? audioId;
  final String name;
  final String? image;
  final String type;
  final String? audio;
  final String? pdf;
  final String? audioDuration;
  final String? description;
  final int isPremium;
  final int? priceInLocal;
  final int? priceInForeign;
  final int played;
  final String status;
  final int? audiobookId;
  final int? seasonId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isCategory;
  @override
  String get title => name;

  BookItem({
    required this.id,
    this.audioId,
    required this.name,
    this.image,
    required this.type,
    this.audio,
    this.pdf,
    this.audioDuration,
    this.description,
    required this.isPremium,
    this.priceInLocal,
    this.priceInForeign,
    required this.played,
    required this.status,
    this.audiobookId,
    this.seasonId,
    this.createdAt,
    this.updatedAt,
    this.isCategory,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing BookItem with data: $json');

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

      final item = BookItem(
        id: safeParseInt(json['id']),
        audioId: safeParseNullableInt(json['audio_id']),
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString(),
        type: json['type']?.toString() ?? '',
        audio: json['audio']?.toString(),
        pdf: json['pdf']?.toString(),
        audioDuration: json['audio_duration']?.toString(),
        description: json['description']?.toString(),
        isPremium: safeParseInt(json['is_premium']),
        priceInLocal: safeParseNullableInt(json['price_in_local']),
        priceInForeign: safeParseNullableInt(json['price_in_foreign']),
        played: safeParseInt(json['played']),
        status: json['status']?.toString() ?? '',
        audiobookId: safeParseNullableInt(json['audiobook_id']),
        seasonId: safeParseNullableInt(json['season_id']),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : null,
        isCategory: json['is_category']??false,
      );
      print('Successfully parsed BookItem');
      return item;
    } catch (e, stackTrace) {
      print('Error parsing BookItem: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }
}

class SearchPurchasesProvider extends ChangeNotifier {
  final Dio _dio;

  SearchPurchasesProvider({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '${dotenv.env['BASE_URL']}/',
              connectTimeout: Duration(seconds: 10),
              receiveTimeout: Duration(seconds: 10),
            ));

  bool _isLoading = false;
  String? _errorMessage;
  List<MediaItem> _results = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MediaItem> get results => List.unmodifiable(_results);

  Future<void> fetchPurchases({
    required String query,
    required String type,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _results = [];
    notifyListeners();

    try {
      final String url =
          '${dotenv.env['BASE_URL']}/search-purchases?query=$query&type=$type';
      final response = await _dio.get(url,
          options: Options(headers: {
            "Authorization": "Bearer ${HivePrefs.getString('token')}"
          }));

      print(
          'search response ${response.data}  type $type query $query url $url');

      if (response.statusCode == 200) {
        final data = response.data;
        if (type == 'audio' && data['audio'] != null) {
          final audioResponse = AudioResponse.fromJson(data);
          _results = audioResponse.audio;
        } else if (type == 'video' && data['video'] != null) {
          final videoResponse = VideoResponse.fromJson(data);
          _results = videoResponse.video;
        } else if (type == 'book' && data['book'] != null) {
          final bookResponse = BookResponse.fromJson(data);
          _results = bookResponse.book;
        } else {
          _errorMessage = 'Invalid response format';
        }
      } else {
        _errorMessage = 'Request failed: ${response.statusCode}';
      }
    } on DioError catch (dioErr) {
      if (dioErr.response != null) {
        _errorMessage =
            'Error ${dioErr.response?.statusCode}: ${dioErr.response?.statusMessage}';
      } else {
        _errorMessage = dioErr.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isLoading = false;
    _errorMessage = null;
    _results = [];
    notifyListeners();
  }
}
