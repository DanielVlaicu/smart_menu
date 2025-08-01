import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://firebase-storage-141030912906.europe-west1.run.app';


  static Future<Map<String, String>> _authHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");
    debugPrint('Bearer token: $token');

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Upload imagine în Google Cloud Storage (prin FastAPI)
  static Future<String> uploadImage(File imageFile) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
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

  static Future<List<dynamic>> getCategories() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Eroare la preluarea categoriilor");
    }
  }

  static Future<void> createCategory({
    required String title,
    required String imagePath,
    required bool visible,
    required int order,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/categories'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = title
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString()
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la crearea categoriei');
    }
  }



  static Future<void> updateCategory({
    required String id,
    required String title,
    required String imagePath,
    required bool visible,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/categories/$id'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = title
      ..fields['visible'] = visible.toString();

    if (imagePath.startsWith('/')) {
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea categoriei');
    }
  }


  static Future<void> deleteCategory(String id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la ștergerea categoriei');
    }
  }

  static Future<void> updateCategoryOrder({
    required String id,
    required int order,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id/order'),
      headers: await _authHeaders(),
      body: {'order': order.toString()},
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea ordinii categoriei');
    }
  }

  /// === SUBCATEGORII ===

  static Future<List<Map<String, dynamic>>> getSubcategories(String categoryId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId/subcategories'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Eroare la preluarea subcategoriilor');
    }
  }

  static Future<void> createSubcategory({
    required String title,
    required String imagePath,
    required bool visible,
    required String categoryId,
    required int order,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/categories/$categoryId/subcategories'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = title
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString()
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la crearea subcategoriei');
    }
  }



  static Future<void> updateSubcategory({
    required String id,
    required String title,
    required String imagePath,
    required bool visible,
    required String categoryId,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$id'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = title
      ..fields['visible'] = visible.toString();

    if (imagePath.startsWith('/')) {
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea subcategoriei');
    }
  }


  static Future<void> deleteSubcategory({
    required String categoryId,
    required String id,
  }) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la ștergerea subcategoriei');
    }
  }

  static Future<void> updateSubcategoryOrder({
    required String categoryId,
    required String id,
    required int order,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$id/order'),
      headers: await _authHeaders(),
      body: {'order': order.toString()},
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea ordinii subcategoriei');
    }
  }

  /// === PRODUSE ===

  static Future<List<Map<String, dynamic>>> getProducts({
    required String categoryId,
    required String subcategoryId,
  }) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$subcategoryId/products'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Eroare la preluarea produselor');
    }
  }
  static Future<void> createProduct({
    required String name,
    required String description,
    required String imagePath,
    required String weight,
    required String allergens,
    required String price,
    required bool visible,
    required String categoryId,
    required String subcategoryId,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$subcategoryId/products'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = description
      ..fields['weight'] = weight
      ..fields['allergens'] = allergens
      ..fields['price'] = price
      ..fields['visible'] = visible.toString()
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la crearea produsului');
    }
  }



  static Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required String imagePath,
    required String weight,
    required String allergens,
    required String price,
    required bool visible,
    required String categoryId,
    required String subcategoryId,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$subcategoryId/products/$id'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = description
      ..fields['weight'] = weight
      ..fields['allergens'] = allergens
      ..fields['price'] = price
      ..fields['visible'] = visible.toString();

    if (imagePath.startsWith('/')) {
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea produsului');
    }
  }


  static Future<void> deleteProduct({
    required String categoryId,
    required String subcategoryId,
    required String id,
  }) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$subcategoryId/products/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la ștergerea produsului');
    }
  }
}
