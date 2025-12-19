// lib/pages/home.page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_project_9ach/models/product.model.dart';
import 'package:mini_project_9ach/services/FavoriteService.dart';
import 'package:mini_project_9ach/services/product_service.dart';
import 'package:mini_project_9ach/utils/constants.dart';
import 'package:mini_project_9ach/widgets/custom_appbar.widget.dart';
import 'package:mini_project_9ach/widgets/custom_drawer.widget.dart';
import 'package:mini_project_9ach/widgets/product_list.widget.dart';
import 'package:mini_project_9ach/widgets/recommended_section.widget.dart'; // Widget séparé

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  String searchString = "";
  List<String> selectedCategories = [];
  List<String> availableCategories = [];
  bool isLoadingCategories = true;
  bool isLoadingProducts = true;
  bool isLoadingRecommendations = true;

  List<Product> allProducts = [];
  List<Product> recommendedProducts = [];

  late ValueListenable<Box> _favoritesListenable;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();

    _favoritesListenable = Hive.box('favorites').listenable();
    _favoritesListenable.addListener(_updateRecommendationsFromFavorites);
  }

  @override
  void dispose() {
    _favoritesListenable.removeListener(_updateRecommendationsFromFavorites);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ProductService.getCategories();
      if (mounted) {
        setState(() {
          availableCategories = categories;
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      print("Erreur chargement catégories : $e");
      if (mounted) {
        setState(() => isLoadingCategories = false);
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoadingProducts = true;
      isLoadingRecommendations = true;
    });

    try {
      final products = await ProductService.getAllProducts();
      final favoriteIds = await FavoriteService.getFavoriteIds();

      if (mounted) {
        setState(() {
          allProducts = products;
          recommendedProducts = _getRecommendedProducts(products, favoriteIds);
          isLoadingProducts = false;
          isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      print("ERREUR CHARGEMENT PRODUITS : $e");
      if (mounted) {
        setState(() {
          allProducts = [];
          recommendedProducts = [];
          isLoadingProducts = false;
          isLoadingRecommendations = false;
        });
      }
    }
  }

  void _updateRecommendationsFromFavorites() async {
    if (allProducts.isEmpty) return;

    final favoriteIds = await FavoriteService.getFavoriteIds();

    if (mounted) {
      setState(() {
        recommendedProducts = _getRecommendedProducts(allProducts, favoriteIds);
        isLoadingRecommendations = false;
      });
    }
  }

  List<Product> _getRecommendedProducts(
      List<Product> allProducts, List<String> favoriteIds) {
    const int maxRecommendations = 10;

    final List<int> favoriteIntIds = favoriteIds
        .map((id) => int.tryParse(id) ?? 0)
        .where((id) => id > 0)
        .toList();

    if (allProducts.isEmpty || favoriteIntIds.isEmpty) {
      final sorted = List<Product>.from(allProducts)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return sorted.take(maxRecommendations).toList();
    }

    final Set<String> favoriteCategories = {};
    for (final id in favoriteIntIds) {
      final product = allProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => Product(
            id: 0,
            title: '',
            price: 0,
            category: '',
            image: '',
            description: '',
            rating: 0,
            ratingCount: 0),
      );
      if (product.category.isNotEmpty) {
        favoriteCategories.add(product.category);
      }
    }

    List<Product> candidates = allProducts.where((p) {
      return favoriteCategories.contains(p.category) &&
          !favoriteIntIds.contains(p.id);
    }).toList();

    if (candidates.length < maxRecommendations) {
      final topGlobal = allProducts
          .where((p) => !favoriteIntIds.contains(p.id))
          .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

      for (final p in topGlobal) {
        if (candidates.length >= maxRecommendations) break;
        if (!candidates.contains(p)) candidates.add(p);
      }
    }

    candidates.sort((a, b) => b.rating.compareTo(a.rating));
    return candidates.take(maxRecommendations).toList();
  }

  void _updateSearch() {
    setState(() {
      searchString = searchController.text.trim();
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  Future<void> _onRefresh() async {
    searchController.clear();
    selectedCategories.clear();
    await Future.wait([
      _loadProducts(),
      _loadCategories(),
    ]);
    _updateSearch();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = allProducts.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(searchString.toLowerCase());
      final matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(product.category);
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: [
            // 1. Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => _updateSearch(),
                  decoration: InputDecoration(
                    hintText: "Rechercher un produit...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              _updateSearch();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // 2. Filtres par catégorie
            if (isLoadingCategories)
              const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator())
            else if (availableCategories.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucune catégorie disponible"))
            else
              SizedBox(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: availableCategories.length,
                  itemBuilder: (context, index) {
                    final category = availableCategories[index];
                    final isSelected = selectedCategories.contains(category);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) => _toggleCategory(category),
                        selectedColor: primaryColor,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                            color: isSelected ? Colors.white : primaryColor,
                            fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side:
                              BorderSide(color: primaryColor.withOpacity(0.3)),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // 3. Section Recommandations
            RecommendedSection(
              recommendedProducts: recommendedProducts,
              isLoading: isLoadingRecommendations,
            ),

            const SizedBox(height: 24),

            // 4. Section New Arrival
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'NEW ARRIVAL',
                    style: TextStyle(
                        fontSize: 22,
                        letterSpacing: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Image.asset("assets/images/bar.png", height: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Liste des produits
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                allProducts.isEmpty
                                    ? "Aucun produit disponible"
                                    : "Aucun produit ne correspond à vos filtres",
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              if (allProducts.isEmpty) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadProducts,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Réessayer"),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ProductList(products: filteredProducts),
            ),
          ],
        ),
      ),
    );
  }
}
