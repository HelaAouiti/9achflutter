import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mini_project_9ach/models/product.model.dart';
import 'package:mini_project_9ach/services/product_service.dart';
import 'package:mini_project_9ach/utils/constants.dart';
import 'package:mini_project_9ach/widgets/custom_appbar.widget.dart';
import 'package:mini_project_9ach/widgets/custom_drawer.widget.dart';
import 'package:mini_project_9ach/widgets/product_list.widget.dart';

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
  bool isLoadingProducts = true; // indique le chargement des produits

  List<Product> allProducts = []; // tous les produits chargés
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadCategories();
    _loadProducts();
  }

  // Chargement de l'email de l'utilisateur connecté (Hive)
  Future<void> _loadUserEmail() async {
    final box = await Hive.openBox('users');
    if (box.isNotEmpty && mounted) {
      setState(() {
        userEmail = box.keys.first as String;
      });
    }
  }

  // Chargement des catégories
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

  // Chargement des produits (version fiable)
  Future<void> _loadProducts() async {
    setState(() {
      isLoadingProducts = true;
    });

    try {
      final products = await ProductService.getAllProducts();
      print("PRODUITS CHARGÉS : ${products.length}");

      if (mounted) {
        setState(() {
          allProducts = products;
          isLoadingProducts = false;
        });
      }
    } catch (e) {
      print("ERREUR CHARGEMENT PRODUITS : $e");
      if (mounted) {
        setState(() {
          allProducts = [];
          isLoadingProducts = false;
        });
      }
    }
  }

  // Mise à jour de la recherche
  void _updateSearch() {
    setState(() {
      searchString = searchController.text.trim();
    });
  }

  // Toggle catégorie
  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  // Refresh complet
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filtrage local (instantané)
    final filteredProducts = allProducts.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(searchString.toLowerCase());
      final matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(product.category);
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      drawer: userEmail != null ? CustomDrawer(userEmail: userEmail!) : null,
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            // Barre de recherche
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

            // Filtres par catégorie
            if (isLoadingCategories)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
            else if (availableCategories.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Aucune catégorie disponible"),
              )
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
                          fontWeight: FontWeight.w500,
                        ),
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

            const SizedBox(height: 16),

            // Titre "NEW ARRIVAL"
            Column(
              children: [
                Text(
                  'NEW ARRIVAL',
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 10,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Image.asset("assets/images/bar.png", height: 12),
              ],
            ),

            const SizedBox(height: 16),

            // Liste des produits
            Expanded(
              child: isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
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
