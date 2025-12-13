// lib/services/favorite_service.dart

import 'package:hive/hive.dart';

class FavoriteService {
  static const String _boxName = 'favorites';
  static const String _keyPrefix = 'fav_';

  static Future<Box> _getBox() => Hive.openBox(_boxName);

  static Future<void> toggleFavorite(String productId) async {
    final box = await _getBox();
    final key = '$_keyPrefix$productId';

    if (box.containsKey(key)) {
      await box.delete(key);
    } else {
      await box.put(key, true);
    }
  }

  static Future<bool> isFavorite(String productId) async {
    final box = await _getBox();
    return box.containsKey('$_keyPrefix$productId');
  }

  static Future<List<String>> getFavoriteIds() async {
    final box = await _getBox();
    return box.keys
        .where((key) => key.toString().startsWith(_keyPrefix))
        .map((key) => key.toString().substring(_keyPrefix.length))
        .cast<String>()
        .toList();
  }

  static Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
