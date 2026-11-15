import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_model.dart';

class FavoriteService {
  static const String keyFavorites = 'favorite_characters';

  static Future<List<Character>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favList = prefs.getStringList(keyFavorites);
    if (favList == null) return [];

    return favList.map((item) => Character.fromJson(jsonDecode(item))).toList();
  }

  static Future<bool> isFavorite(int characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favList = prefs.getStringList(keyFavorites);
    if (favList == null) return false;

    return favList.any((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == characterId;
    });
  }

  static Future<bool> toggleFavorite(Character character) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favList = prefs.getStringList(keyFavorites) ?? [];

    final index = favList.indexWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == character.id;
    });

    if (index >= 0) {
      // Hapus dari favorit
      favList.removeAt(index);
      await prefs.setStringList(keyFavorites, favList);
      return false; // Sekarang tidak favorit
    } else {
      // Tambah ke favorit
      favList.add(jsonEncode(character.toJson()));
      await prefs.setStringList(keyFavorites, favList);
      return true; // Sekarang favorit
    }
  }

  static Future<void> removeFavorite(int characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favList = prefs.getStringList(keyFavorites) ?? [];

    favList.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == characterId;
    });

    await prefs.setStringList(keyFavorites, favList);
  }
}
