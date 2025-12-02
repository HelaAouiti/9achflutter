// lib/pages/product_details.page.dart (VERSION PRO – BOUTON FIXE EN BAS)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.model.dart';
import '../services/cart.service.dart';
import '../pages/cart.page.dart';
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
  int quantity = 1;

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
          duration: Duration(seconds: 1)),
    );
  }

  void _addToCart() {
    final cartService = Provider.of<CartService>(context, listen: false);
    cartService.addToCart(currentProduct, quantity: quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$quantity article(s) ajouté(s) au panier !"),
        backgroundColor: primaryColor,
        action: SnackBarAction(
          label: "VOIR LE PANIER",
          textColor: Colors.white,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CartPage())),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final isInCart = cartService.isInCart(currentProduct);

    return Scaffold(
      extendBody: true, // Important pour le bouton en bas
      appBar: AppBar(
        title: const Text("Détail du produit"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<CartService>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartPage())),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenu défilable
          SingleChildScrollView(
            padding: const EdgeInsets.all(16)
                .copyWith(bottom: 100), // Espace pour le bouton
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Image ===
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    currentProduct.image,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : Container(
                                height: 350,
                                color: Colors.grey[200],
                                child: const Center(
                                    child: CircularProgressIndicator())),
                    errorBuilder: (_, __, ___) => Container(
                      height: 350,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          size: 80, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // === Titre + Favori ===
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

                // === Prix + Note ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${currentProduct.price.toStringAsFixed(2)} €",
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 6),
                        Text(
                            "${currentProduct.rating.toStringAsFixed(1)} (${currentProduct.ratingCount} avis)"),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text("Catégorie : ${currentProduct.category}",
                    style: TextStyle(color: Colors.grey[700])),

                const Divider(height: 40),

                // === Description + Commentaires ===
                const Text("Description",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(currentProduct.description,
                    style: const TextStyle(fontSize: 15, height: 1.6)),

                const Divider(height: 40),

                const Text("Commentaires",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Champ commentaire
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Écrivez votre commentaire...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: primaryColor, width: 2),
                    ),
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: primaryColor),
                        onPressed: _addComment),
                  ),
                  onSubmitted: (_) => _addComment(),
                ),

                const SizedBox(height: 20),

                // Liste des commentaires
                currentProduct.comments.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("Soyez le premier à commenter !",
                            style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentProduct.comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                                radius: 18,
                                backgroundColor: primaryColor,
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(currentProduct.comments[index],
                                    style: const TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),

                const SizedBox(height: 100), // Espace pour le bouton fixe
              ],
            ),
          ),

          // BOUTON FIXE EN BAS
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  // Sélecteur de quantité
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => setState(
                              () => quantity = quantity > 1 ? quantity - 1 : 1),
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        child: Text("$quantity",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                          onPressed: () => setState(() => quantity++),
                          icon: const Icon(Icons.add_circle,
                              color: primaryColor)),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Bouton Ajouter au panier
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: Icon(isInCart ? Icons.check : Icons.shopping_cart),
                      label: Text(
                          isInCart ? "Déjà au panier" : "Ajouter au panier",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isInCart ? Colors.grey[600] : primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
