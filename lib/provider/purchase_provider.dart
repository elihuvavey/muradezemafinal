import 'package:muradezema/utils/dio_client.dart';
// providers/purchase_provider.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muradezema/utils/user_prefs.dart';
import 'dart:convert';

class PurchaseItem {
  final int? id;
  final int? albumId;
  final int? languageId;
  final int? audioId;
  final int? podcastId;
  final int? audiobookId;
  final int? seasonId;
  final String? title;
  final String? name;
  final String? image;
  final String? audio;
  final String? pdf;
  final String? type;
  final String? duration;
  final String? audioDuration;
  final String? description;
  final int? isPremium;
  final int? statusInt;
  final String? status;
  final String? genre;
  final int? priceInLocal;
  final int? priceInForeign;
  final String? date;
  final int? played;
  final bool? isCategory;
  final bool? isPurchased;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseItem({
    this.id,
    this.albumId,
    this.languageId,
    this.audioId,
    this.podcastId,
    this.audiobookId,
    this.seasonId,
    this.title,
    this.name,
    this.image,
    this.audio,
    this.pdf,
    this.type,
    this.duration,
    this.audioDuration,
    this.description,
    this.isPremium,
    this.statusInt,
    this.status,
    this.genre,
    this.priceInLocal,
    this.priceInForeign,
    this.date,
    this.played,
    this.isCategory,
    this.createdAt,
    this.updatedAt,
    this.isPurchased,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: _toInt(json['id']),
      albumId: _toInt(json['album_id']),
      languageId: _toInt(json['language_id']),
      audioId: _toInt(json['audio_id']),
      podcastId: _toInt(json['podcast_id']),
      audiobookId: _toInt(json['audiobook_id']),
      seasonId: _toInt(json['season_id']),
      title: json['title'],
      name: json['name'],
      image: json['image'],
      audio: json['audio'],
      pdf: json['pdf'],
      type: json['type']?.toString(),
      duration: json['duration'],
      audioDuration: json['audio_duration'],
      description: json['description'],
      isPremium: _toInt(json['is_premium']),
      statusInt: _toInt(json['status']),
      status: json['status'] is String ? json['status'] : null,
      genre: json['genre'],
      priceInLocal: _toInt(json['price_in_local']),
      priceInForeign: _toInt(json['price_in_foreign']),
      date: json['date'],
      played: _toInt(json['played']),
      isCategory: json['is_category'],
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      isPurchased: json['is_purchased']??false,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class PurchaseProvider with ChangeNotifier {
  final Dio _dio = createDio();
  List<PurchaseItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<PurchaseItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add method to check if an audio item is purchased
  bool isAudioPurchased(int audioId) {
    final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];
    return purchasedIds.contains(audioId.toString());
  }

  // Add method to print saved audio IDs
  void printSavedAudioIds() {
    final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];
    print('Saved purchased audio IDs: $purchasedIds');
  }

  Future<void> fetchPurchases({required String type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = '${dotenv.env['BASE_URL']}/my-purchases?type=$type';

    try {
      final response = await _dio.get(url,
          options: Options(headers: {
            'Authorization': 'Bearer ${HivePrefs.getString('token')}'
          }));
      print('response purchase ${response.data}');

      if (response.statusCode == 200) {
        final List data = response.data;
        _items = data.map((json) => PurchaseItem.fromJson(json)).toList();

        // Save purchased audio information to HivePrefs if type is audio
        if (type == 'audio') {
          final purchasedAudios = _items
              .map((item) => {
                    'id': item.id.toString(),
                    'title': item.title ?? '',
                    'description': item.description ?? '',
                    'image': item.image ?? '',
                    'duration': item.duration ?? '',
                  })
              .toList();
          await HivePrefs.saveStringList('purchased_audio_ids',
              _items.map((item) => item.id.toString()).toList());
          await HivePrefs.saveString(
              'purchased_audio_info', jsonEncode(purchasedAudios));
          print('Saved purchased audio information: $purchasedAudios');
        }
      } else {
        _error = 'Failed with status code ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      print('error $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
