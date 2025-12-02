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
  String? userEmail;

  // On supprime le late final → on recrée le Future à chaque build ou refresh
  Future<List<Product>>? productsFuture;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadCategories();
    _loadProducts(); // On charge les produits ici
  }

  Future<void> _loadProducts() async {
    setState(() {
      productsFuture = ProductService.getAllProducts().then((products) {
        print("PRODUITS CHARGÉS : ${products.length}");
        return products;
      }).catchError((error) {
        print("ERREUR PRODUITS : $error");
        return <Product>[]; // Retourne liste vide en cas d'erreur
      });
    });
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

  Future<void> _loadUserEmail() async {
    final box =
        await Hive.openBox('users'); // Assure-toi que la box est ouverte
    if (box.isNotEmpty && mounted) {
      setState(() {
        userEmail = box.keys.first as String;
      });
    }
  }

  void _updateSearch() {
    setState(() {
      searchString = searchController.text.trim();
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      selectedCategories.contains(category)
          ? selectedCategories.remove(category)
          : selectedCategories.add(category);
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _loadProducts(),
      _loadCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
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
                  onChanged: (_) => _updateSearch(), // Plus réactif
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

            // Filtres catégories
            if (isLoadingCategories)
              const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator())
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Titre
            Column(
              children: [
                Text('NEW ARRIVAL',
                    style: TextStyle(
                        fontSize: 22,
                        letterSpacing: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Image.asset("assets/images/bar.png", height: 12),
              ],
            ),

            const SizedBox(height: 16),

            // Liste des produits
            Expanded(
              child: productsFuture == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<Product>>(
                      future: productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Erreur de chargement"),
                                ElevatedButton(
                                  onPressed: _loadProducts,
                                  child: Text("Réessayer"),
                                ),
                              ],
                            ),
                          );
                        }

                        final products = snapshot.data ?? [];
                        if (products.isEmpty) {
                          return const Center(
                              child: Text("Aucun produit disponible"));
                        }

                        final filtered = products.where((p) {
                          final matchesSearch = p.title
                              .toLowerCase()
                              .contains(searchString.toLowerCase());
                          final matchesCat = selectedCategories.isEmpty ||
                              selectedCategories.contains(p.category);
                          return matchesSearch && matchesCat;
                        }).toList();

                        if (filtered.isEmpty) {
                          return const Center(
                              child: Text(
                                  "Aucun produit trouvé avec ces filtres"));
                        }

                        return ProductList(products: filtered);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
