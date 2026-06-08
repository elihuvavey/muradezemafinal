import 'package:muradezema/utils/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/user_prefs.dart';

class SongModel {
  final int? id;
  final String? albumId;
  final String? languageId;
  final String? title;
  final String? image;
  final String? audio;
  final String? type;
  final String? duration;
  final String? description;
  final String? isPremium;
  final String? status;
  final String? genre;
  final String? priceInLocal;
  final String? priceInForeign;
  final String? date;
  final String? createdAt;
  final String? updatedAt;
  final String? artistName;
  final bool? isPurchased;

  SongModel({
    this.id,
    this.albumId,
    this.languageId,
    this.title,
    this.image,
    this.audio,
    this.type,
    this.duration,
    this.description,
    this.isPremium,
    this.status,
    this.genre,
    this.priceInLocal,
    this.priceInForeign,
    this.date,
    this.artistName,
    this.isPurchased,
    this.createdAt,
    this.updatedAt,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
        id: json['id'],
        albumId: json['album_id']?.toString(),
        languageId: json['language_id']?.toString(),
        title: json['title'],
        image: json['image'],
        audio: json['audio'],
        type: json['type']?.toString(),
        duration: json['duration'],
        description: json['description'],
        isPremium: json['is_premium']?.toString(),
        status: json['status']?.toString(),
        genre: json['genre'],
        priceInLocal: json['price_in_local']?.toString(),
        priceInForeign: json['price_in_foreign']?.toString(),
        date: json['date'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        isPurchased: json['is_purchased'],
        artistName: json['artist_name']);
  }
}

class AudioServices {
  final Dio _dio = createDio();

  Future<List<SongModel>> fetchSongsByAlbumId(String albumId) async {
    final String url = '${dotenv.env['BASE_URL']}/audio/songList/$albumId';
    try {
      final response = await _dio.get(url,
          options: Options(headers: {
            
          }));

      print('tracks  [36m${response.data}');
      if (response.statusCode == 200) {
        List data = response.data['data'];
        return data.map((json) => SongModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load songs');
      }
    } catch (e) {
      throw Exception('Error fetching songs: $e');
    }
  }
}

class SeasonEpisodeProvider with ChangeNotifier {
  final AudioServices _audioService = AudioServices();
  List<SongModel> _songs = [];
  bool _isLoading = false;
  String? _error;

  List<SongModel> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSongs(String albumId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _songs = await _audioService.fetchSongsByAlbumId(albumId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  SongModel? getEpisodeById(String id) {
    try {
      return _songs.firstWhere((song) => song.id.toString() == id);
    } catch (e) {
      return null;
    }
  }
}
