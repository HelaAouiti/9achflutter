// lib/widgets/product_card.widget.dart

import 'package:flutter/material.dart';
import 'package:mini_project_9ach/services/FavoriteService.dart';
import '../models/product.model.dart';
import '../pages/product_details.page.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // On garde une copie locale du produit pour pouvoir le modifier
  late Product _currentProduct;

@override
void initState() {
  super.initState();
  _currentProduct = widget.product;
  _loadFavoriteStatus();
}

Future<void> _loadFavoriteStatus() async {
  final isFav = await FavoriteService.isFavorite(widget.product.id.toString());
  if (mounted) {
    setState(() {
      _currentProduct = _currentProduct.copyWith(isFavorite: isFav);
    });
  }
}

  // Important : si le parent envoie un nouveau produit (ex: après refresh), on met à jour
  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product) {
      _currentProduct = widget.product;
    }
  }

void _toggleFavorite() async {
  final newFavorite = !_currentProduct.isFavorite;

  setState(() {
    _currentProduct = _currentProduct.copyWith(isFavorite: newFavorite);
  });

  // Sauvegarde persistante
  await FavoriteService.toggleFavorite(_currentProduct.id.toString());
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // On passe la version actuelle (avec favori à jour)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: _currentProduct),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              Image.network(
                _currentProduct.image,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),

              // Bouton Favori
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child: IconButton(
                    iconSize: 20,
                    icon: Icon(
                      _currentProduct.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _currentProduct.isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),

              // Infos en bas
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentProduct.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentProduct.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _currentProduct.rating.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}