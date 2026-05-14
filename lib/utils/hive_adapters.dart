import 'package:hive/hive.dart';

class HiveAdapters {
  static void registerAdapters() {
    // Register adapters here
    Hive.registerAdapter(FavoritesAdapter());
  }
}

class FavoritesAdapter extends TypeAdapter<Map<String, Map<String, bool>>> {
  @override
  final int typeId = 0; // Choose a unique typeId

  @override
  Map<String, Map<String, bool>> read(BinaryReader reader) {
    final map = reader.readMap();
    final result = <String, Map<String, bool>>{};

    map.forEach((key, value) {
      if (value is Map) {
        final innerMap = <String, bool>{};
        value.forEach((innerKey, innerValue) {
          if (innerValue is bool) {
            // Ensure innerKey is always a String
            final stringKey = innerKey.toString();
            innerMap[stringKey] = innerValue;
          }
        });
        result[key.toString()] = innerMap;
      }
    });

    return result;
  }

  @override
  void write(BinaryWriter writer, Map<String, Map<String, bool>> obj) {
    // Ensure all keys are strings before writing
    final map = <String, Map<String, bool>>{};
    obj.forEach((key, value) {
      final innerMap = <String, bool>{};
      value.forEach((innerKey, innerValue) {
        innerMap[innerKey.toString()] = innerValue;
      });
      map[key.toString()] = innerMap;
    });
    writer.writeMap(map);
  }
}
