import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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


  ///initialiare  categorii subcategorii si produse (primele cand isi creeaza cont)

  static Future<void> initializeUser() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    // Încarcă fișierele din assets ca MultipartFile
    Future<http.MultipartFile> loadAsset(String path, String field) async {
      final byteData = await rootBundle.load(path);
      final file = http.MultipartFile.fromBytes(
        field,
        byteData.buffer.asUint8List(),
        filename: path.split('/').last,
      );
      return file;
    }

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/initialize'))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await loadAsset('lib/assets/images/default_category.png', 'category_file'))
      ..files.add(await loadAsset('lib/assets/images/default_subcategory.png', 'subcategory_file'))
      ..files.add(await loadAsset('lib/assets/images/default_product.png', 'product_file'));

    final response = await request.send();
    if (response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      throw Exception('Eroare la initialize: $respStr');
    }
  }

  /// === CATEGORII ===

  static Future<List<dynamic>> getCategories() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    );

    debugPrint('GET /categories => ${response.statusCode}');
    debugPrint('BODY: ${response.body}'); // ✅ adaugă asta!

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
    required int order,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/categories/$id'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = title
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString();

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
    required String title,
    required bool visible,
    required int order,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/categories/$id'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = title
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString();

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea ordinii categoriei');
    }
  }

  static Future<void> reorderCategories(List<Map<String, dynamic>> ordered) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/categories/reorder'),
      headers: headers,
      body: jsonEncode({'items': ordered}),
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la reordonarea categoriilor');
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
    required int order,
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
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString();

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
    required String title,
    required bool visible,
    required int order,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/categories/$categoryId/subcategories/$id'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = title
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString();

    final response = await request.send();
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
    required double price,
    required bool visible,
    required String categoryId,
    required String subcategoryId,
    required int order,
    required bool protected,
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
      ..fields['price'] = price.toString()
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString()
      ..fields['protected'] = protected.toString()
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
    required double price,
    required bool visible,
    required String categoryId,
    required String subcategoryId,
    required int order,
    required bool protected,
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
      ..fields['price'] = price.toString()
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString()
      ..fields['protected'] = protected.toString();
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


  static Future<void> updateProductOrder({
    required String categoryId,
    required String subcategoryId,
    required String id,
    required String name,
    required String description,
    required String weight,
    required String allergens,
    required double price,
    required bool visible,
    required int order,
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
      ..fields['price'] = price.toString()
      ..fields['visible'] = visible.toString()
      ..fields['order'] = order.toString();

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Eroare la actualizarea ordinii produsului');
    }
  }

  ///////// Nume Brand si background restaurant


// GET /branding

  static Future<Map<String, dynamic>> getBranding() async {
    final headers = await _authHeaders();
    final resp = await http.get(Uri.parse('$baseUrl/branding'), headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Eroare la preluarea brandingului');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

// PUT /branding (nume și/sau imagine)
  static Future<Map<String, dynamic>> updateBranding({
    String? name,
    String? imagePath,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Utilizator neautentificat");

    final req = http.MultipartRequest('PUT', Uri.parse('$baseUrl/branding'))
      ..headers['Authorization'] = 'Bearer $token';

    if (name != null) req.fields['name'] = name;
    if (imagePath != null && imagePath.isNotEmpty) {
      req.files.add(await http.MultipartFile.fromPath('file', imagePath));
    }

    final resp = await req.send();
    final body = await resp.stream.bytesToString();
    if (resp.statusCode != 200) {
      throw Exception('Eroare la actualizarea brandingului: $body');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }



  static Future<void> submitPublicReview({
    required String restaurantUid,
    String? email,
    String? phone,
    required String message,
    String? imagePath,
    File? imageFile,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/public-menu/$restaurantUid/reviews'),
    );

    if (email != null && email.isNotEmpty) req.fields['email'] = email;
    if (phone != null && phone.isNotEmpty) req.fields['phone'] = phone;
    req.fields['message'] = message;

    if (imageFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final resp = await req.send();
    final body = await resp.stream.bytesToString();

    if (resp.statusCode != 200) {
      throw Exception('Eroare la trimiterea review-ului: $body');
    }
  }

  static Future<List<Map<String, dynamic>>> getReviews() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Eroare la încărcarea recenziilor');
    }
  }

}


