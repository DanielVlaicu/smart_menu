import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://your-backend-url.com/api';

  /// Upload imagine în Google Cloud Storage (prin FastAPI)
  static Future<String> uploadImage(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return data['url'];
    } else {
      throw Exception('Eroare la upload imagine');
    }
  }

  /// === CATEGORII ===

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Eroare la preluarea categoriilor');
    }
  }

  static Future<void> createCategory({
    required String title,
    required String imageUrl,
    required bool visible,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'image_url': imageUrl,
        'visible': visible,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la crearea categoriei');
    }
  }

  static Future<void> updateCategory({
    required String id,
    required String title,
    required String imageUrl,
    required bool visible,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'image_url': imageUrl,
        'visible': visible,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea categoriei');
    }
  }

  static Future<void> deleteCategory(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));
    if (response.statusCode != 200) {
      throw Exception('Eroare la ștergerea categoriei');
    }
  }

  /// === SUBCATEGORII ===

  static Future<List<Map<String, dynamic>>> getSubcategories(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/subcategories?category=$categoryId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Eroare la preluarea subcategoriilor');
    }
  }

  static Future<void> createSubcategory({
    required String title,
    required String imageUrl,
    required bool visible,
    required String categoryId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subcategories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'image_url': imageUrl,
        'visible': visible,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la crearea subcategoriei');
    }
  }

  static Future<void> updateSubcategory({
    required String id,
    required String title,
    required String imageUrl,
    required bool visible,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subcategories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'image_url': imageUrl,
        'visible': visible,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea subcategoriei');
    }
  }

  static Future<void> deleteSubcategory(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/subcategories/$id'));
    if (response.statusCode != 200) {
      throw Exception('Eroare la ștergerea subcategoriei');
    }
  }

  /// === PRODUSE ===

  static Future<List<Map<String, dynamic>>> getProducts(String subcategoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/products?subcategory=$subcategoryId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Eroare la preluarea produselor');
    }
  }

  static Future<void> createProduct({
    required String title,
    required String description,
    required String imageUrl,
    required String weight,
    required String allergens,
    required String price,
    required bool visible,
    required String subcategoryId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'weight': weight,
        'allergens': allergens,
        'price': price,
        'visible': visible,
        'subcategory_id': subcategoryId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la crearea produsului');
    }
  }

  static Future<void> updateProduct({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required String weight,
    required String allergens,
    required String price,
    required bool visible,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'weight': weight,
        'allergens': allergens,
        'price': price,
        'visible': visible,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea produsului');
    }
  }

  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Eroare la ștergerea produsului');
    }
  }
}
