// lib/pages/favorites_page.dart

import 'package:flutter/material.dart';
import 'package:mini_project_9ach/models/product.model.dart';
import 'package:mini_project_9ach/services/FavoriteService.dart';
import 'package:mini_project_9ach/services/product_service.dart';
import 'package:mini_project_9ach/widgets/product_list.widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Product>> favoriteProductsFuture;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() {
      favoriteProductsFuture = _getFavoriteProducts();
    });
  }

  Future<List<Product>> _getFavoriteProducts() async {
    final allProducts = await ProductService.getAllProducts();
    final favoriteIds = await FavoriteService.getFavoriteIds();

    return allProducts
        .where((product) => favoriteIds.contains(product.id.toString()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Favoris"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavoriteProducts,
        child: FutureBuilder<List<Product>>(
          future: favoriteProductsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Erreur : ${snapshot.error}"),
              );
            }

            final favorites = snapshot.data ?? [];

            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      "Aucun favori pour le moment",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Découvrir les produits"),
                    ),
                  ],
                ),
              );
            }

            return ProductList(products: favorites);
          },
        ),
      ),
    );
  }
}
