import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  static Future<List<Character>> getCharacters({String? status, String? name}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((item) => Character.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        // Karakter tidak ditemukan untuk filter/search tertentu
        return [];
      } else {
        throw Exception('Gagal memuat karakter (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Character> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Character.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail karakter (Status Code: ${response.statusCode})');
    }
  }
}
