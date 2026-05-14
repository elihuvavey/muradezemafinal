import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class FavoriteProvider with ChangeNotifier {
  static const String _boxName = 'favorites';
  late Box<Map<dynamic, dynamic>> _favoritesBox;

  // Map to store favorites with composite key of type and id
  Map<String, Map<String, Map<String, dynamic>>> _favorites = {
    'audio': {},
    'video': {},
    'book': {},
  };

  FavoriteProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _favoritesBox = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    _loadFavorites();
  }

  void _loadFavorites() {
    final savedFavorites = _favoritesBox.get('favorites');
    if (savedFavorites != null) {
      try {
        // Convert all keys to strings and ensure proper type structure
        _favorites = Map<String, Map<String, Map<String, dynamic>>>.from(
          savedFavorites.map((key, value) {
            if (value is Map) {
              final innerMap = <String, Map<String, dynamic>>{};
              value.forEach((innerKey, innerValue) {
                if (innerValue is Map) {
                  innerMap[innerKey.toString()] =
                      Map<String, dynamic>.from(innerValue);
                }
              });
              return MapEntry(key.toString(), innerMap);
            }
            return MapEntry(key.toString(), <String, Map<String, dynamic>>{});
          }),
        );
        debugPrint('Favorites loaded: $_favorites');
      } catch (e) {
        print('Error loading favorites: $e');
        // If loading fails, start with empty favorites
        _favorites = {
          'audio': {},
          'video': {},
          'book': {},
        };
        debugPrint('Favorites reset to empty due to error.');
      }
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    await _favoritesBox.put('favorites', _favorites);
    debugPrint('Favorites saved: $_favorites');
  }

  // Get all favorites
  Map<String, Map<String, Map<String, dynamic>>> get favorites => _favorites;

  // Check if item is favorite
  bool isFavorite(String type, String id) {
    final result = _favorites[type]?.containsKey(id) ?? false;
    return result;
  }

  // Get favorites by type
  Map<String, Map<String, dynamic>> getFavoritesByType(String type) {
    final result = _favorites[type] ?? {};
    debugPrint('getFavoritesByType called for type: $type, result: $result');
    return result;
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String type, String id,
      {String? title,
      String? description,
      String? image,
      required bool isPurchased}) async {
    debugPrint('toggleFavorite called for type: $type, id: $id');
    if (!_favorites.containsKey(type)) {
      _favorites[type] = {};
      debugPrint('Type $type did not exist, initialized.');
    }

    if (isFavorite(type, id)) {
      _favorites[type]!.remove(id);
      debugPrint('Removed favorite for type: $type, id: $id');
    } else {
      _favorites[type]![id] = {
        'isFavorite': true,
        'title': title ?? '',
        'description': description ?? '',
        'image': image ?? '',
        'isPurchased': isPurchased,
      };
      debugPrint(
          'Added favorite for type: $type, id: $id, data: ${_favorites[type]![id]}');
    }
    await _saveFavorites();
    notifyListeners();
  }

  // Add to favorites
  Future<void> addFavorite(String type, String id,
      {required String title,
      required String description,
      required String image,
      required bool isPurchased}) async {
    debugPrint('addFavorite called for type: $type, id: $id');
    if (!_favorites.containsKey(type)) {
      _favorites[type] = {};
      debugPrint('Type $type did not exist, initialized.');
    }

    _favorites[type]![id] = {
      'isFavorite': true,
      'title': title,
      'description': description,
      'image': image,
      'isPurchased': isPurchased,
    };
    debugPrint(
        'Added favorite for type: $type, id: $id, data: ${_favorites[type]![id]}');
    await _saveFavorites();
    notifyListeners();
  }

  // Remove from favorites
  Future<void> removeFavorite(String type, String id) async {
    debugPrint('removeFavorite called for type: $type, id: $id');
    if (_favorites.containsKey(type)) {
      _favorites[type]!.remove(id);
      debugPrint('Removed favorite for type: $type, id: $id');
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    debugPrint('clearFavorites called');
    _favorites.forEach((key, value) => value.clear());
    await _saveFavorites();
    notifyListeners();
    debugPrint('All favorites cleared');
  }

  // Clear favorites by type
  Future<void> clearFavoritesByType(String type) async {
    debugPrint('clearFavoritesByType called for type: $type');
    if (_favorites.containsKey(type)) {
      _favorites[type]?.clear();
      await _saveFavorites();
      notifyListeners();
      debugPrint('Favorites cleared for type: $type');
    }
  }

  @override
  void dispose() {
    debugPrint('FavoriteProvider disposed');
    _favoritesBox.close();
    super.dispose();
  }
}
