// lib/pages/product_details.page.dart

import 'package:flutter/material.dart';
import '../models/product.model.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Product currentProduct;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
  }

  void _toggleFavorite() {
    setState(() {
      currentProduct = currentProduct.copyWith(
        isFavorite: !currentProduct.isFavorite,
      );
    });
  }

  void _addComment() {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      currentProduct = currentProduct.copyWith(
        comments: [text, ...currentProduct.comments],
      );
      commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Commentaire ajouté !"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du produit"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                currentProduct.image,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 350,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 350,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      size: 80, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Titre + Favori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentProduct.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  iconSize: 36,
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    currentProduct.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: currentProduct.isFavorite
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Prix + Note
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${currentProduct.price.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      "${currentProduct.rating.toStringAsFixed(1)} (${currentProduct.ratingCount} avis)",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              "Catégorie : ${currentProduct.category}",
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),

            const Divider(height: 32),

            // Description
            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              currentProduct.description,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),

            const Divider(height: 40),

            // Section commentaires
            const Text("Commentaires",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Champ de commentaire
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Écrivez votre commentaire...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _addComment,
                ),
              ),
              onSubmitted: (_) => _addComment(),
            ),

            const SizedBox(height: 20),

            // Liste des commentaires
            currentProduct.comments.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Soyez le premier à commenter !",
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentProduct.comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentProduct.comments[index],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

            const SizedBox(height: 40),

            // Bouton Acheter
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Fonctionnalité d'achat bientôt disponible !")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                child: const Text(
                  "Acheter maintenant",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
