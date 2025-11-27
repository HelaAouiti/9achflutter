// lib/services/product_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.model.dart';

class ProductService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));

      // CORRIGÉ : interpolation correcte
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print('Nombre de produits reçus: ${jsonResponse.length}');

        return jsonResponse.map((data) => Product.fromJson(data)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('ERREUR RÉSEAU: $e');
      rethrow;
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/categories'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final categories = jsonResponse.cast<String>();
        print('Catégories: $categories');
        return categories;
      } else {
        throw Exception('Erreur catégories: ${response.statusCode}');
      }
    } catch (e) {
      print('ERREUR CATÉGORIES: $e');
      return ["men's clothing", "jewelery", "electronics", "women's clothing"];
    }
  }
}
