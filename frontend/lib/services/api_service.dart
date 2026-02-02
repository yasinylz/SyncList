import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/checklist.dart';
import '../models/category.dart';
import '../models/item.dart';

/// API Service
class ApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  /// Tüm kategorileri getir
  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Kategoriler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Yeni kategori oluştur
  static Future<Category> createCategory(String name, String? icon) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/categories'),
        headers: _headers,
        body: json.encode({'name': name, 'icon': icon}),
      );
      if (response.statusCode == 201) {
        return Category.fromJson(json.decode(response.body));
      } else {
        throw Exception('Kategori oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Kategori güncelle
  static Future<Category> updateCategory(
    int id,
    String name,
    String? icon,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/categories/$id'),
        headers: _headers,
        body: json.encode({'name': name, 'icon': icon}),
      );
      if (response.statusCode == 200) {
        return Category.fromJson(json.decode(response.body));
      } else {
        throw Exception('Kategori güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Kategori sil
  static Future<void> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/categories/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        String errorMessage = 'Kategori silinemedi.';
        try {
          final body = json.decode(response.body);
          if (body['details'] != null)
            errorMessage = body['details'];
          else if (body['error'] != null)
            errorMessage = body['error'];
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().startsWith('Exception:')) rethrow;
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Tüm listeleri getir
  static Future<List<Checklist>> getChecklists() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/checklists'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Checklist.fromJson(json)).toList();
      } else {
        throw Exception('Listeler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Tek bir listeyi getir
  static Future<Checklist> getChecklist(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/checklists/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return Checklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Liste bulunamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Yeni liste oluştur
  static Future<Checklist> createChecklist(
    String title,
    int? categoryId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/checklists'),
        headers: _headers,
        body: json.encode({'title': title, 'categoryId': categoryId}),
      );
      if (response.statusCode == 201) {
        return Checklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Liste oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Liste güncelle
  static Future<Checklist> updateChecklist(
    int id,
    String title,
    int? categoryId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/checklists/$id'),
        headers: _headers,
        body: json.encode({'title': title, 'categoryId': categoryId}),
      );
      if (response.statusCode == 200) {
        return Checklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Liste güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Liste sil
  static Future<void> deleteChecklist(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/checklists/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Liste silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Listeye ait maddeleri getir
  static Future<List<Item>> getItems(int checklistId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items/$checklistId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Item.fromJson(json)).toList();
      } else {
        throw Exception('Maddeler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Yeni madde ekle
  static Future<Item> createItem(String taskName, int checklistId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/items'),
        headers: _headers,
        body: json.encode({
          'taskName': taskName,
          'checklistId': checklistId,
          'isCompleted': false,
        }),
      );
      if (response.statusCode == 201) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw Exception('Madde eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Madde tamamlanma durumunu değiştir
  static Future<Item> toggleItem(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/items/$id/toggle'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw Exception('Madde güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Madde güncelle
  static Future<Item> updateItem(int id, String taskName) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/items/$id'),
        headers: _headers,
        body: json.encode({'taskName': taskName}),
      );
      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw Exception('Madde güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Madde sil
  static Future<void> deleteItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/items/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Madde silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
